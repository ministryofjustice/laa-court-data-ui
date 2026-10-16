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

# Known, accepted axe-core finding: GOV.UK Design System sort links have an `aria-label` that
# does not match the visible link text, which axe flags as a `label-content-name-mismatch` violation. This is a known
# issue with the MoJ Design System's sortable table component, which is used in the case summary page.
# See https://design-patterns.service.justice.gov.uk/components/sortable-table/
GOVUK_HEADING_SORT_ARIA_MISMATCH_EXCLUSION = AxeResults::ExclusionRule.new(
  id: "label-content-name-mismatch",
  selector: "a[aria-label^='Sort']",
)
