# frozen_string_literal: true

class HomeView < Phlex::HTML
  def view_template
    h1 { "Welcome" }

    # Good: img with alt
    img(src: "hero.jpg", alt: "Hero banner")

    # Bad: img missing alt (ImgMissingAlt)
    img(src: "logo.png")

    # Good: image_tag with alt
    image_tag("photo.jpg", alt: "A photo")

    # Bad: image_tag missing alt (ImageTagMissingAlt)
    image_tag("icon.png")

    # Good: area with alt
    area(shape: "rect", href: "/sun", alt: "Sun")

    # Bad: area missing alt (AreaMissingAlt)
    area(shape: "rect", href: "/sun")

    # Good: link_to with text
    link_to("Home", root_path)

    # Bad: link_to with empty string (LinkToMissingAccessibleName)
    link_to("", "/profile", class: "icon")

    # Good: link_to with aria-label
    link_to("", "/settings", aria: { label: "Settings" })

    # Bad: button_tag with empty string (ButtonTagMissingAccessibleName)
    button_tag("", class: "close-btn")

    # Good: button_tag block with icon + text (has accessible name)
    button_tag(class: "button-icon") do
      inline_svg("icon.svg")
      span { t(".suggest") }
    end

    # Bad: button_tag block with icon only (ButtonTagMissingAccessibleName)
    button_tag(class: "button-icon") do
      span(class: "icon-menu")
    end

    # Good: input type="image" with alt
    input(type: "image", src: "submit.png", alt: "Submit")

    # Bad: input type="image" missing alt (InputImageMissingAlt)
    input(type: "image", src: "submit.png")

    # Good: image_submit_tag with alt
    image_submit_tag("submit.png", alt: "Submit")

    # Bad: image_submit_tag missing alt (ImageSubmitTagMissingAlt)
    image_submit_tag("submit.png")

    # Good: input with autocomplete
    input(type: "email", name: "email", autocomplete: "email")

    # Bad: input missing autocomplete (InputMissingAutocomplete)
    input(type: "text", name: "username")

    # Good: anchor with text
    a(href: "/home") { plain "Home" }

    # Bad: empty anchor (AnchorMissingAccessibleName)
    a(href: "/profile", class: "icon")

    # Good: anchor with aria-label
    a(href: "/settings", aria_label: "Settings")

    # Good: anchor with img with alt
    a(href: "/home") { img(src: "home.svg", alt: "Home") }

    # Bad: anchor with img without alt (AnchorMissingAccessibleName)
    a(href: "/home") { img(src: "home.svg") }

    # Good: button with text
    button(type: "submit") { plain "Submit" }

    # Bad: empty button (ButtonMissingAccessibleName)
    button(type: "button", class: "close")

    # Good: button with aria-label
    button(type: "button", aria_label: "Close")

    # Good: button with img with alt
    button(type: "button") { img(src: "close.svg", alt: "Close") }

    # Bad: button with img without alt (ButtonMissingAccessibleName)
    button(type: "button") { img(src: "close.svg") }

    # Good: ul with only li children
    ul do
      li { "First" }
      li { "Second" }
    end

    # Bad: ul with a div child (ListInvalidChildren)
    ul do
      div { "Not allowed" }
      li { "Item" }
    end
  end
end
