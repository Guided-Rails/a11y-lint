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
