# frozen_string_literal: true

require "cgi"
require "zip"
require "nokogiri"

module Shuby
  module Articles
    class ParseError < StandardError; end

    # Reads a single .docx file and returns a hash of structured content
    # suitable for an ArchiveContent record:
    #
    #   {
    #     title:       String,
    #     description: String,
    #     body_html:   String,         # ActionText-ready HTML
    #     age_min:     0..36 Integer,
    #     age_max:     0..36 Integer,
    #     word_count:  Integer
    #   }
    #
    # The .docx is a zipped XML container; word/document.xml carries the
    # paragraph stream and word/numbering.xml lets us decide <ol> vs <ul>.
    #
    # Pipeline: collect_paragraphs walks the body once into structured records,
    # extract_title/extract_description pick out the leading title and lede
    # paragraph and mark them consumed, render_html emits the surviving
    # records as HTML. Consuming title + description here keeps the body_html
    # free of duplicates that the show view would otherwise render twice
    # alongside record.title and record.description.
    class DocxParser
      # Filenames use looser conventions ("Sonno_0-12.docx", "(12–24 mesi)",
      # "da 9 a 12 mesi"), so we accept the underscore/parenthesis form even
      # without an explicit "mes" suffix.
      FILENAME_AGE_PATTERNS = [
        /[_(\s](\d+)\s*[-–—]\s*(\d+)\s*mes/i,
        /da\s+(\d+)\s+a\s+(\d+)\s+mes/i,
        /[_(](\d+)\s*[-–—]\s*(\d+)\b/
      ].freeze

      # Body patterns must require an explicit "mes" anchor — otherwise we'd
      # match unrelated numeric ranges in prose ("4-12 ore", "10-14 ore totali").
      BODY_AGE_PATTERNS = [
        /(\d+)\s*[-–—]\s*(\d+)\s*mes/i,
        /da\s+(\d+)\s+a\s+(\d+)\s+mes/i
      ].freeze

      SINGLE_AGE_PATTERN = /(\d+)\s*mesi?(?:\s|$|\.)/i

      # Most articles declare their age band in a footer line
      # ("Fascia d'età: 12-24 mesi"), well past the 600-char body cap.
      # An explicit anchor lets us scan the whole body without re-introducing
      # the prose false-match risk that AGE_BODY_SCAN_CHARS guards against.
      FOOTER_AGE_PATTERN = /Fascia\s+d['’`]?et[àa]\s*:?\s*(\d+)\s*[-–—]\s*(\d+)\s*mes/i
      FOOTER_SINGLE_AGE_PATTERN = /Fascia\s+d['’`]?et[àa]\s*:?\s*(\d+)\s*mesi?/i

      DESCRIPTION_MIN_LENGTH = 40
      DESCRIPTION_MAX_LENGTH = 160
      AGE_BODY_SCAN_CHARS = 600

      def initialize(path)
        @path = Pathname.new(path)
      end

      def parse
        document_xml, numbering_xml = read_xml
        @list_format_by_id = parse_numbering(numbering_xml)

        document = Nokogiri::XML(document_xml)
        document.remove_namespaces!

        paragraphs = collect_paragraphs(document)
        consumed = []

        title = extract_title(paragraphs, consumed) || filename_title
        description = extract_description(paragraphs, consumed, title)
        body_html = render_html(paragraphs.reject.with_index { |_, i| consumed.include?(i) })
        age_min, age_max = detect_age_range(paragraphs)
        word_count = paragraphs.sum { |p| p[:text].split(/\s+/).reject(&:empty?).size }

        {
          title: title,
          description: description,
          body_html: body_html,
          age_min: age_min,
          age_max: age_max,
          word_count: word_count
        }
      rescue Zip::Error, Nokogiri::SyntaxError => e
        raise ParseError, "#{@path.basename}: #{e.message}"
      end

      private

      def read_xml
        Zip::File.open(@path) do |zip|
          document = zip.find_entry("word/document.xml")&.get_input_stream&.read
          numbering = zip.find_entry("word/numbering.xml")&.get_input_stream&.read
          raise ParseError, "Missing word/document.xml in #{@path}" unless document
          return [document, numbering]
        end
      end

      # Maps Word numId references to :ol or :ul. abstractNum holds the format,
      # num maps numId → abstractNumId. We only inspect ilvl=0 — nested lists
      # render flat (acceptable for the article corpus).
      def parse_numbering(xml)
        return {} unless xml

        doc = Nokogiri::XML(xml)
        doc.remove_namespaces!

        abstract = {}
        doc.xpath("//abstractNum").each do |abs|
          fmt = abs.at_xpath("./lvl[@ilvl='0']/numFmt")&.[]("val")
          abstract[abs["abstractNumId"]] = ((fmt == "decimal") ? :ol : :ul)
        end

        doc.xpath("//num").each_with_object({}) do |num, h|
          abs_id = num.at_xpath("./abstractNumId")&.[]("val")
          h[num["numId"]] = abstract[abs_id] || :ul
        end
      end

      # Walks <w:body>//<w:p> once and returns an array of structured records.
      # Each record holds the typed shape, the inline-emphasis HTML for
      # rendering, and the plain decoded text for extraction matching.
      #
      # Record shape:
      #   { type: :heading | :paragraph | :list_item,
      #     level: 2 | 3 | 4 | nil,
      #     list_tag: :ul | :ol | nil,
      #     num_id: String | nil,
      #     html:  String,           # inline runs, escaped + emphasis tags
      #     text:  String }          # decoded plain text, used for matching
      def collect_paragraphs(document)
        body = document.at_xpath("//body")
        return [] unless body

        title_style_used = false

        body.xpath(".//p").filter_map do |paragraph|
          html = paragraph_inner_html(paragraph)
          text = decode_entities(strip_inline_tags(html)).gsub(/\s+/, " ").strip
          next if html.strip.empty? && text.empty?

          num_id = paragraph.at_xpath("./pPr/numPr/numId")&.[]("val")
          if num_id
            {
              type: :list_item,
              level: nil,
              list_tag: @list_format_by_id[num_id] || :ul,
              num_id: num_id,
              html: html,
              text: text
            }
          else
            style_val = paragraph.at_xpath("./pPr/pStyle")&.[]("val").to_s.downcase
            # "Title" style is single-use in Word docs; subsequent
            # "Title"-styled paragraphs are author errors (the lede gets
            # styled like the title). Demote them to body paragraphs.
            effective_style = if style_val == "title"
              if title_style_used
                nil
              else
                title_style_used = true
                "title"
              end
            else
              style_val
            end
            level = heading_level(effective_style)
            {
              type: level ? :heading : :paragraph,
              level: level,
              list_tag: nil,
              num_id: nil,
              html: html,
              text: text
            }
          end
        end
      end

      def heading_level(style_val)
        case style_val.to_s.downcase
        when "title", "heading1", "heading2" then 2
        when "heading3" then 3
        when "heading4", "heading5", "heading6" then 4
        end
      end

      # Walks all <w:r> descendants so we cover runs wrapped in <w:hyperlink>,
      # <w:ins> (tracked-change inserts), and other containers. Runs inside
      # <w:del> are author-removed content from track-changes mode — skipped.
      def paragraph_inner_html(paragraph)
        runs = paragraph.xpath(".//r[not(ancestor::del)]")
        runs.map { |r| render_run(r) }.join
      end

      def render_run(run)
        text = run.children.map do |child|
          case child.name
          when "t" then ERB::Util.html_escape(child.text)
          when "tab" then " "
          when "br" then "<br>"
          else ""
          end
        end.join

        return "" if text.empty?

        run_props = run.at_xpath("./rPr")
        text = "<strong>#{text}</strong>" if run_props&.at_xpath("./b")
        text = "<em>#{text}</em>" if run_props&.at_xpath("./i")
        text
      end

      # First heading paragraph wins as title. Marks its index consumed so the
      # body_html doesn't repeat the title that show.html.erb already renders
      # in <h1>.
      def extract_title(paragraphs, consumed)
        idx = paragraphs.index { |p| p[:type] == :heading }
        return nil unless idx
        consumed << idx
        paragraphs[idx][:text]
      end

      # First substantive paragraph after the title (≥ 40 chars, not the title
      # itself) seeds a brief snippet for the description field. The lede is
      # NOT marked consumed — it stays in body_html as the article's opening
      # paragraph, so the show view reads cleanly from line one.
      def extract_description(paragraphs, consumed, title)
        title_idx = consumed.first || -1
        lede = paragraphs.each_with_index.find do |p, i|
          i > title_idx &&
            p[:type] == :paragraph &&
            p[:text].length >= DESCRIPTION_MIN_LENGTH &&
            p[:text] != title
        end&.first

        return build_snippet(lede[:text]) if lede

        combined = paragraphs.map { |p| p[:text] }.join(" ").gsub(/\s+/, " ").strip
        build_snippet(combined)
      end

      # Brief snippet from a longer paragraph. Prefers cutting at a sentence
      # terminator (./!/? followed by whitespace or end-of-string) within the
      # cap; falls back to a word-boundary trim with an ellipsis when no
      # terminator fits.
      def build_snippet(text)
        return text if text.length <= DESCRIPTION_MAX_LENGTH
        head = text[0, DESCRIPTION_MAX_LENGTH]
        if (m = head.match(/\A.*[.!?](?=\s|$)/m))
          m[0]
        else
          truncate_at_word(text, DESCRIPTION_MAX_LENGTH)
        end
      end

      # Emits HTML from a (filtered) list of paragraph records, grouping
      # consecutive list_items with the same num_id into one <ul> or <ol>.
      def render_html(paragraphs)
        parts = []
        list_buffer = nil

        paragraphs.each do |p|
          if p[:type] == :list_item
            if list_buffer && list_buffer[:tag] == p[:list_tag] && list_buffer[:num_id] == p[:num_id]
              list_buffer[:items] << p[:html]
            else
              flush_list(list_buffer, parts)
              list_buffer = {tag: p[:list_tag], num_id: p[:num_id], items: [p[:html]]}
            end
            next
          end

          flush_list(list_buffer, parts)
          list_buffer = nil
          parts << render_block(p)
        end

        flush_list(list_buffer, parts)
        parts.compact.join("\n")
      end

      def flush_list(buffer, parts)
        return unless buffer && !buffer[:items].empty?
        items = buffer[:items].map { |c| "<li>#{c}</li>" }.join
        parts << "<#{buffer[:tag]}>#{items}</#{buffer[:tag]}>"
      end

      def render_block(p)
        case p[:type]
        when :heading
          "<h#{p[:level]}>#{p[:html]}</h#{p[:level]}>"
        when :paragraph
          "<p>#{p[:html]}</p>"
        end
      end

      def detect_age_range(paragraphs)
        if (range = match_filename(@path.basename(".docx").to_s))
          return clamp_range(*range)
        end

        full_text = paragraphs.map { |p| p[:text] }.join(" ")
        if (range = match_footer(full_text))
          return clamp_range(*range)
        end

        scan_text = full_text.slice(0, AGE_BODY_SCAN_CHARS).to_s
        if (range = match_body(scan_text))
          return clamp_range(*range)
        end

        [0, 36]
      end

      def match_footer(text)
        if (m = text.match(FOOTER_AGE_PATTERN))
          return [m[1].to_i, m[2].to_i]
        end
        if (m = text.match(FOOTER_SINGLE_AGE_PATTERN))
          v = m[1].to_i
          return [v, v]
        end
        nil
      end

      def match_filename(text)
        FILENAME_AGE_PATTERNS.each do |re|
          if (m = text.match(re))
            return [m[1].to_i, m[2].to_i]
          end
        end
        nil
      end

      def match_body(text)
        BODY_AGE_PATTERNS.each do |re|
          if (m = text.match(re))
            return [m[1].to_i, m[2].to_i]
          end
        end
        if (m = text.match(SINGLE_AGE_PATTERN))
          v = m[1].to_i
          return [v, v]
        end
        nil
      end

      def clamp_range(min, max)
        min = min.clamp(0, 36)
        max = max.clamp(0, 36)
        min, max = max, min if min > max
        [min, max]
      end

      def filename_title
        raw = @path.basename(".docx").to_s
        # Source filenames often write apostrophes as underscores between
        # letters ("L_alternanza" → "L'alternanza"). Restore them so titles
        # read naturally.
        raw.gsub(/([A-Za-zÀ-ÿ])_([A-Za-zÀ-ÿ])/, "\\1'\\2").strip
      end

      def strip_inline_tags(html)
        html.gsub(/<\/?(?:strong|em|br)\s*\/?>/i, "")
      end

      def decode_entities(text)
        CGI.unescapeHTML(text)
      end

      def truncate_at_word(text, limit)
        return text if text.length <= limit
        head = text[0, limit].rpartition(" ").first
        head = text[0, limit] if head.empty?
        "#{head}…"
      end
    end
  end
end
