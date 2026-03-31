---
description: Rules for writing tests
globs: test/**/*.rb
---

- Do not use `setup` methods. Instead, create the necessary objects inline within each test method.

  Bad:
  ```ruby
  def setup
    @offense = Offense.new(
      rule: "ImgMissingAlt",
      filename: "test.slim",
      line: 1,
      message: "missing alt"
    )
  end

  def test_rule
    assert_equal("ImgMissingAlt", @offense.rule)
  end
  ```

  Good:
  ```ruby
  def test_rule
    offense = Offense.new(
      rule: "ImgMissingAlt",
      filename: "test.slim",
      line: 1,
      message: "missing alt"
    )

    assert_equal("ImgMissingAlt", offense.rule)
  end
  ```

- Rules that inspect `ruby_code` (e.g. `link_to`, `image_tag` helpers) must include test cases for all three calling styles:
  1. Single-line with parentheses: `= link_to("", "/path", class: "icon")`
  2. Single-line without parentheses: `= link_to "", "/path", class: "icon"`
  3. Multiline with trailing comma:
     ```slim
     = link_to(\
         "",
         "/path",
         class: "icon",
       )
     ```

  Each style must be tested for both the offense case and the "passes with fix" case.

- Every rule must be tested against both the Slim and ERB pipelines.
