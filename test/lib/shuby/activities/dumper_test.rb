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
    end
  end
end
