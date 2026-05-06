# frozen_string_literal: true

class HomeView < Phlex::HTML
  def view_template(label: "Menu")
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

    # Good: link_to block with image_tag having non-empty alt
    link_to("/home") do
      image_tag("home.svg", alt: "Home")
    end

    # Good: button_tag block with image_tag having non-empty alt
    button_tag(class: "button-icon") do
      image_tag("home.svg", alt: "Home")
    end

    # Bad: button_tag block whose only text is inside a hidden wrapper
    # Needs hidden_wrapper_classes: [popover] config
    # (ButtonTagMissingAccessibleName)
    button_tag(class: "button-icon") do
      span(class: "popover") { plain "Move" }
      inline_svg("thumbs-up.svg")
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

    # Good: anchor with translated text via phlex-rails value helper
    a(href: "/dashboard") { t(".dashboard") }

    # Bad: empty anchor (AnchorMissingAccessibleName)
    a(href: "/profile", class: "icon")

    # Good: anchor with aria-label
    a(href: "/settings", aria_label: "Settings")

    # Good: anchor with nested aria: { label: ... } shorthand
    a(href: "/notifications", aria: { label: t(".notifications") })

    # Good: anchor with img with alt
    a(href: "/home") { img(src: "home.svg", alt: "Home") }

    # Bad: anchor with img without alt (AnchorMissingAccessibleName)
    a(href: "/home") { img(src: "home.svg") }

    # Good: button with text
    button(type: "submit") { plain "Submit" }

    # Good: button with translated text via phlex-rails value helper
    button(type: "submit") { t(".submit") }

    # Bad: empty button (ButtonMissingAccessibleName)
    button(type: "button", class: "close")

    # Good: button with aria-label
    button(type: "button", aria_label: "Close")

    # Good: button with nested aria: { label: ... } shorthand
    button(type: "button", aria: { label: t(".close") })

    # Good: button with img with alt
    button(type: "button") { img(src: "close.svg", alt: "Close") }

    # Bad: button with img without alt (ButtonMissingAccessibleName)
    button(type: "button") { img(src: "close.svg") }

    # Good: anchor with bare string-literal block (Phlex auto-emits)
    a(href: "/clear", class: "text-sm") { "Clear all" }

    # Good: anchor whose block returns a method call value
    a(href: "/profile", class: "link") { current_user_email }

    # Good: anchor with positional-arg text content (Phlex auto-emits)
    a("View profile", href: "/profile", class: "link")

    # Good: anchor with translated positional arg
    a(t(".dashboard"), href: "/dashboard")

    # Good: anchor with sr-only label among icon component siblings
    a(href: "/back", class: "...") do
      span(class: "sr-only") { "Back to " }
      span { label }
    end

    # Good: anchor whose accessible name lives in an sr-only span
    # whose body is an ambiguous bare call (`label` is an instance
    # method, not the `<label>` HTML tag).
    # Needs accessible_name_wrapper_classes: [sr-only] config.
    a(href: "/back", class: "icon") do
      span(class: "absolute -inset-2.5")
      span(class: "sr-only") { label }
      ChevronLeft(variant: :solid, class: "size-5")
    end

    # Good: button whose accessible name lives in an sr-only span
    # with the same bare-call shape.
    # Needs accessible_name_wrapper_classes: [sr-only] config.
    button(class: "icon") do
      span(class: "absolute -inset-2.5")
      span(class: "sr-only") { label }
      EllipsisVertical(variant: :solid, class: "size-5")
    end

    # Good: button with bare string-literal block
    button(type: :submit, class: "btn") { "Filter" }

    # Good: button whose block returns a local variable
    button(type: "submit", class: "btn") { label }

    # Good: button with positional-arg text content (Phlex auto-emits)
    button("Submit", type: :submit, class: "btn")

    # Good: button with translated positional arg
    button(t(".save"), type: :submit)

    # Good: wrapper methods (defined below) forward &block to a/button.
    # Accessible name is provided by the caller's block, which the linter
    # can't see from the wrapper site, so the &block forward is trusted.
    icon_link("/back") { span { "Back" } }
    icon_button { span { "Save" } }

    # Bad: anchor whose only child is a capitalized Phlex component
    # (AnchorMissingAccessibleName)
    a(href: "/somewhere") { Pencil(variant: :solid, class: "size-4") }

    # Bad: anchor with whitespace-only string literal block
    # (AnchorMissingAccessibleName)
    a(href: "/x") { "   " }

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

  # Good: wrapper forwards &block to <a> — caller supplies the text.
  def icon_link(href, &block)
    a(href:, class: "icon-link", &block)
  end

  # Good: wrapper forwards &block to <button> — caller supplies the text.
  def icon_button(&block)
    button(type: "button", class: "icon-button", &block)
  end
end
