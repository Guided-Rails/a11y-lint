# frozen_string_literal: true

require "test_helper"

module A11y
  module Lint
    class TestErbRunner < Minitest::Test
      def test_for_clean_source
        offenses = run_linter('<img src="photo.jpg" alt="A photo">')

        assert_empty(offenses)
      end

      def test_img_without_alt
        offenses = run_linter('<img src="photo.jpg">')

        assert_equal(1, offenses.length)
      end

      def test_rule_name
        offenses = run_linter('<img src="photo.jpg">')

        assert_equal("ImgMissingAlt", offenses[0].rule)
      end

      def test_filename
        offenses = run_linter(
          '<img src="photo.jpg">',
          filename: "app/views/show.html.erb"
        )

        assert_equal("app/views/show.html.erb", offenses[0].filename)
      end

      def test_line_number
        source = <<~ERB
          <div>
            <img src="photo.jpg">
          </div>
        ERB

        offenses = run_linter(source)

        assert_equal(2, offenses[0].line)
      end

      def test_message
        offenses = run_linter('<img src="photo.jpg">')

        assert_equal(
          "img tag is missing an alt attribute (WCAG 1.1.1)",
          offenses[0].message
        )
      end

      def test_image_tag_without_alt
        offenses = run_linter('<%= image_tag "photo.jpg" %>')

        assert_equal(1, offenses.length)
        assert_equal("ImageTagMissingAlt", offenses[0].rule)
      end

      def test_image_tag_with_alt
        offenses = run_linter('<%= image_tag "photo.jpg", alt: "A photo" %>')

        assert_empty(offenses)
      end

      def test_line_numbers_across_multiple_elements
        offenses = run_linter(multiline_source)

        assert_equal(2, offenses.length)
        assert_equal(3, offenses[0].line)
        assert_equal(5, offenses[1].line)
      end

      def test_erb_mixed_with_html
        source = <<~ERB
          <img src="a.jpg">
          <%= image_tag "b.jpg" %>
        ERB

        offenses = run_linter(source)

        assert_equal(2, offenses.length)
        assert_equal("ImgMissingAlt", offenses[0].rule)
        assert_equal("ImageTagMissingAlt", offenses[1].rule)
      end

      def test_non_output_erb_tags_ignored
        offenses = run_linter(
          '<% if condition %><img src="photo.jpg" alt="ok"><% end %>'
        )

        assert_empty(offenses)
      end

      def test_img_with_erb_attribute_preserves_alt
        source = '<img src="<%= asset_path("photo.jpg") %>" alt="A photo">'

        offenses = run_linter(source)

        assert_empty(offenses)
      end

      def test_multiline_erb_output_tag
        source = <<~ERB
          <div>
          <%= image_tag "photo.jpg",
                        class: "hero" %>
          </div>
        ERB

        offenses = run_linter(source)

        assert_equal(1, offenses.length)
        assert_equal(2, offenses[0].line)
      end

      def test_trim_mode_erb_tag
        offenses = run_linter('<%= image_tag "photo.jpg" -%>')

        assert_equal(1, offenses.length)
      end

      def test_self_closing_img
        offenses = run_linter('<img src="photo.jpg" />')

        assert_equal(1, offenses.length)
      end

      def test_html_elements_produce_erb_element_nodes
        nodes = collect_nodes('<img src="photo.jpg">')

        assert_equal(1, nodes.length)
        assert_instance_of(ErbElementNode, nodes[0])
      end

      def test_text_content_for_element_with_static_text
        nodes = collect_nodes('<a href="/">Click me</a>')

        assert(nodes[0].text_content?)
      end

      def test_text_content_for_empty_element
        nodes = collect_nodes('<a href="/"></a>')

        refute(nodes[0].text_content?)
      end

      def test_text_content_for_element_with_erb_output
        nodes = collect_nodes('<a href="/"><%= t("click") %></a>')

        assert(nodes[0].text_content?)
      end

      def test_text_content_for_element_with_only_img_child
        nodes = collect_nodes('<a href="/"><img src="icon.svg"></a>')
        a_node = nodes.find { |n| n.tag_name == "a" }

        refute(a_node.text_content?)
      end

      def test_erb_output_tags_produce_erb_output_nodes
        nodes = collect_nodes('<%= image_tag "photo.jpg" %>')

        assert_equal(1, nodes.length)
        assert_instance_of(ErbOutputNode, nodes[0])
      end

      private

      def multiline_source
        <<~ERB
          <div>
            <p>Hello</p>
            <img src="a.jpg">
            <span>World</span>
            <img src="b.jpg">
          </div>
        ERB
      end

      def run_linter(source, filename: "test.html.erb")
        rules = [Rules::ImgMissingAlt, Rules::ImageTagMissingAlt]
        ErbRunner.new(rules).run(source, filename: filename)
      end

      def collect_nodes(source)
        nodes = []
        spy = Class.new(Rule) do
          define_method(:check) do
            nodes << @node
            nil
          end
        end
        ErbRunner.new([spy]).run(source, filename: "test.html.erb")
        nodes
      end
    end
  end
end
