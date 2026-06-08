# frozen_string_literal: true

require "test_helper"
require "stringio"
require "tmpdir"
require "zip"

module Shuby
  module Activities
    class DumperTest < ActiveSupport::TestCase
      # Minimal WordprocessingML: a Heading1 title, two prose paragraphs, and a
      # bold "Fascia d'età" footer — the exact shape of docs/Activities files.
      # The parser only needs word/document.xml inside the zip.
      DOCUMENT_XML = <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
          <w:body>
            <w:p><w:pPr><w:pStyle w:val="Heading1"/></w:pPr><w:r><w:t>Gioco di prova</w:t></w:r></w:p>
            <w:p><w:r><w:t>Mostra l'oggetto al bambino e aspetta che lo guardi con attenzione.</w:t></w:r></w:p>
            <w:p><w:r><w:t>Questo rinforza lo scambio di sguardi e la comunicazione precoce.</w:t></w:r></w:p>
            <w:p><w:r><w:rPr><w:b/></w:rPr><w:t>Fascia d'età: 6-12 mesi</w:t></w:r></w:p>
          </w:body>
        </w:document>
      XML

      # Same shape plus the optional labeled lines (Materiali bold, Durata plain,
      # Benefici bold) authors may add — exercises parse-if-present + body strip.
      ENRICHED_DOCUMENT_XML = <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
          <w:body>
            <w:p><w:pPr><w:pStyle w:val="Heading1"/></w:pPr><w:r><w:t>Gioco ricco</w:t></w:r></w:p>
            <w:p><w:r><w:t>Spiega al bambino cosa fare con calma e attenzione.</w:t></w:r></w:p>
            <w:p><w:r><w:rPr><w:b/></w:rPr><w:t>Materiali: scatola, cuscino, pupazzo</w:t></w:r></w:p>
            <w:p><w:r><w:t>Durata: 10 minuti</w:t></w:r></w:p>
            <w:p><w:r><w:rPr><w:b/></w:rPr><w:t>Benefici: Favorisce la comprensione; Stimola il linguaggio</w:t></w:r></w:p>
            <w:p><w:r><w:rPr><w:b/></w:rPr><w:t>Fascia d'età: 12-24 mesi</w:t></w:r></w:p>
          </w:body>
        </w:document>
      XML

      # A bare "Benefici:" header followed by a bulleted list (w:numPr). No
      # numbering.xml needed — DocxParser defaults an unknown numId to :ul.
      BULLET_DOCUMENT_XML = <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
          <w:body>
            <w:p><w:pPr><w:pStyle w:val="Heading1"/></w:pPr><w:r><w:t>Gioco a lista</w:t></w:r></w:p>
            <w:p><w:r><w:t>Prosa introduttiva dell'attività.</w:t></w:r></w:p>
            <w:p><w:r><w:rPr><w:b/></w:rPr><w:t>Benefici:</w:t></w:r></w:p>
            <w:p><w:pPr><w:numPr><w:numId w:val="2"/></w:numPr></w:pPr><w:r><w:t>Favorisce la comprensione</w:t></w:r></w:p>
            <w:p><w:pPr><w:numPr><w:numId w:val="2"/></w:numPr></w:pPr><w:r><w:t>Stimola il linguaggio</w:t></w:r></w:p>
            <w:p><w:r><w:t>Fascia d'età: 12-24 mesi</w:t></w:r></w:p>
          </w:body>
        </w:document>
      XML

      # Builds a one-entry .docx, dumps the containing dir, returns parsed records.
      def dump(xml: DOCUMENT_XML, filename: "Gioco di prova.docx")
        Dir.mktmpdir do |root|
          write_docx(File.join(root, filename), xml)
          out = File.join(root, "out.json")
          Shuby::Activities::Dumper.new(root: root, output_path: out, io: StringIO.new).run
          JSON.parse(File.read(out))
        end
      end

      def write_docx(path, xml)
        Zip::OutputStream.open(path) do |zos|
          zos.put_next_entry("word/document.xml")
          zos.write(xml)
        end
      end

      test "extracts title, slug, prose body and footer age range" do
        record = dump.first

        assert_equal "Gioco di prova", record["title"]
        assert_equal "gioco-di-prova", record["slug"]
        assert_equal 6, record["min_age_months"]
        assert_equal 12, record["max_age_months"]
        assert_equal 1, record["position"]
        assert_includes record["body_html"], "scambio di sguardi"
      end

      test "strips the bold 'Fascia d'età' footer from the body" do
        body = dump.first["body_html"]

        assert_not_includes body, "Fascia"
        assert_not_includes body, "mesi"
        assert_not_includes body, "<strong>"
      end

      test "emits docx-absent fields empty (no materials/benefits/duration, free)" do
        record = dump.first

        assert_nil record["materials"]
        assert_equal [], record["benefits"]
        assert_nil record["duration_minutes"]
        assert_equal false, record["specialist"]
      end

      test "returns false and writes nothing when the source dir is missing" do
        result = Shuby::Activities::Dumper.new(
          root: "/no/such/activities/dir",
          output_path: File.join(Dir.tmpdir, "shuby-dumper-missing.json"),
          io: StringIO.new
        ).run

        assert_equal false, result
      end

      test "parses optional Materiali / Durata / Benefici labeled lines when present" do
        record = dump(xml: ENRICHED_DOCUMENT_XML, filename: "Gioco ricco.docx").first

        assert_equal "scatola, cuscino, pupazzo", record["materials"]
        assert_equal 10, record["duration_minutes"]
        assert_equal ["Favorisce la comprensione", "Stimola il linguaggio"], record["benefits"]
        assert_equal 12, record["min_age_months"]
        assert_equal 24, record["max_age_months"]
      end

      test "strips the parsed labeled lines from the body, keeping only prose" do
        body = dump(xml: ENRICHED_DOCUMENT_XML, filename: "Gioco ricco.docx").first["body_html"]

        assert_includes body, "Spiega al bambino"
        assert_not_includes body, "Materiali"
        assert_not_includes body, "Durata"
        assert_not_includes body, "Benefici"
        assert_not_includes body, "Fascia"
      end

      test "duration takes the first integer from a range value" do
        xml = ENRICHED_DOCUMENT_XML.sub("Durata: 10 minuti", "Durata: 10-15 minuti")
        record = dump(xml: xml, filename: "Gioco ricco.docx").first

        assert_equal 10, record["duration_minutes"]
      end

      test "parses a 'Benefici:' header followed by a bulleted list" do
        record = dump(xml: BULLET_DOCUMENT_XML, filename: "Gioco a lista.docx").first

        assert_equal ["Favorisce la comprensione", "Stimola il linguaggio"], record["benefits"]
        assert_includes record["body_html"], "Prosa introduttiva"
        assert_not_includes record["body_html"], "Benefici"
        assert_not_includes record["body_html"], "<ul>"
        assert_not_includes record["body_html"], "<li>"
      end
    end
  end
end
