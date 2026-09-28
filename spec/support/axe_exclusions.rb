# frozen_string_literal: true

require_relative "axe_results"

# Known, accepted axe-core finding: govuk_design_system_formbuilder renders GOV.UK Design System
# conditional-reveal radio buttons (used for the "Other" unlink reason) with `aria-controls`
# and `aria-expanded` on the radio `<input>` itself. These attributes are not part of the ARIA
# spec's allowed attribute set for `role="radio"`, so axe's `aria-allowed-attr` rule flags them -
# even though this is the GOV.UK Design System's own documented conditional reveal pattern.
# See: https://design-system.service.gov.uk/components/radios/#conditionally-revealing-content
GOVUK_CONDITIONAL_RADIO_ARIA_EXCLUSION = AxeResults::ExclusionRule.new(
  id: "aria-allowed-attr",
  selector: "input[aria-expanded]",
)
