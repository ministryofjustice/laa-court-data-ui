# frozen_string_literal: true

RSpec.feature 'Breadcrumb', type: :feature, stub_unlinked: true do
  let(:user) { create(:user) }
  let(:case_urn) { 'TEST12345' }
  let(:defendant_id) { '41fcb1cd-516e-438e-887a-5987d92ef90f' }
  let(:hearing_id_from_fixture) { '345be88a-31cf-4a30-9de3-da98e973367e' }

  context 'when not signed in' do
    before { visit unauthenticated_root_path }

    it 'breadcrumbs are not displayed' do
      within_breadcrumbs do
        expect(page).not_to have_content(/.+/)
      end
    end
  end

  context 'when signed in' do
    before do
      sign_in user
      visit '/'
    end

    context 'when on search filters page' do
      scenario 'no breadcrumbs are displayed' do
        within '.govuk-breadcrumbs' do
          expect(page).not_to have_content(/.+/)
        end
      end
    end

    context 'when on case reference search page' do
      scenario 'expected breadcrumbs are displayed' do
        when_i_choose_search_filter 'A case by URN'
        then_has_case_ref_search_breadcrumbs
      end
    end

    context 'when on defendant reference search page' do
      scenario 'expected breadcrumbs are displayed' do
        when_i_choose_search_filter 'A defendant by ASN or National insurance number'
        then_has_defendant_ref_search_breadcrumbs
      end
    end

    context 'when on defendant name and dob search page' do
      scenario 'expected breadcrumbs are displayed' do
        when_i_choose_search_filter 'A defendant by name and date of birth'
        then_has_defendant_name_search_breadcrumbs
      end
    end

    context 'when on case details page' do
      scenario 'expected breadcrumbs are displayed' do
        when_i_choose_search_filter 'A case by URN'
        when_i_search_for case_urn

        click_link(case_urn, match: :first)
        expect(page).to have_current_path(prosecution_case_path(case_urn))
        then_has_case_details_breadcrumbs(case_urn)
      end
    end

    context 'when on defendant details page' do
      scenario 'expected breadcrumbs are displayed' do
        when_i_choose_search_filter 'A case by URN'
        when_i_search_for case_urn

        click_link(case_urn, match: :first)
        click_link('Jammy Dodger')
        expect(page).to have_current_path(%r{/laa_references/.+})
        then_has_defendant_details_breadcrumbs(case_urn, 'Jammy Dodger')
      end
    end

    context 'when on hearing details page' do
      scenario 'expected breadcrumbs are displayed' do
        when_i_choose_search_filter 'A case by URN'
        when_i_search_for case_urn

        click_link(case_urn, match: :first)
        click_link('23/10/2019', match: :first)
        expect(page).to have_current_path(hearing_path(hearing_id_from_fixture,
                                                       column: 'date',
                                                       direction: 'asc',
                                                       urn: case_urn,
                                                       page: '0'))
        then_has_hearing_details_breadcrumbs(case_urn, '23/10/2019')
      end
    end

    scenario 'user navigates search, prosecution case, defendant and hearings pages' do
      when_i_choose_search_filter 'A case by URN'
      when_i_search_for case_urn

      click_link(case_urn, match: :first)
      expect(page).to have_current_path(prosecution_case_path(case_urn))
      then_has_case_details_breadcrumbs(case_urn)

      click_link('Jammy Dodger')
      expect(page).to have_current_path(%r{/laa_references/.+})
      then_has_defendant_details_breadcrumbs(case_urn, 'Jammy Dodger')

      click_breadcrumb 'Case TEST12345'
      expect(page).to have_current_path(prosecution_case_path(case_urn))
      then_has_case_details_breadcrumbs(case_urn)

      click_link('23/10/2019', match: :first)
      expect(page).to have_current_path(hearing_path(hearing_id_from_fixture,
                                                     column: 'date',
                                                     direction: 'asc',
                                                     urn: case_urn,
                                                     page: '0'))
      then_has_hearing_details_breadcrumbs(case_urn, '23/10/2019')

      click_breadcrumb 'Search'
      expect(page).to have_current_path(
        searches_path(
          search: {
            filter: 'case_reference',
            term: case_urn
          }
        )
      )
      then_has_case_ref_search_breadcrumbs

      click_breadcrumb 'Home'
      expect(page).to have_current_path(new_search_filter_path)
      then_breadcrumbs_are_not_displayed
    end
  end

  def when_i_choose_search_filter(search_filter_option)
    choose search_filter_option
    click_button 'Continue'
  end

  def when_i_search_for(term)
    fill_in 'search-term-field', with: term
    click_button 'Search'
  end

  def click_breadcrumb(crumb)
    within_breadcrumbs do
      click_link crumb
    end
  end

  def within_breadcrumbs(&block)
    within '.govuk-breadcrumbs' do
      yield block
    end
  end

  def then_breadcrumbs_are_not_displayed
    within_breadcrumbs do
      expect(page).not_to have_content(/.+/)
    end
  end

  def then_has_case_ref_search_breadcrumbs
    expect(page).to have_govuk_breadcrumb_link('Home', href: '/search_filters/new')
    expect(page).not_to have_govuk_breadcrumb_link('Search')
    expect(page).to have_govuk_breadcrumb('Search', aria_current: true)
  end

  def then_has_defendant_ref_search_breadcrumbs
    expect(page).to have_govuk_breadcrumb_link('Home')
    expect(page).not_to have_govuk_breadcrumb_link('Search')
    expect(page).to have_govuk_breadcrumb('Search', aria_current: true)
  end

  def then_has_defendant_name_search_breadcrumbs
    expect(page).to have_govuk_breadcrumb_link('Home')
    expect(page).not_to have_govuk_breadcrumb_link('Search')
    expect(page).to have_govuk_breadcrumb('Search', aria_current: true)
  end

  def then_has_case_details_breadcrumbs(case_ref)
    expect(page).to have_govuk_breadcrumb_link('Home')
    expect(page).to have_govuk_breadcrumb_link(
      'Search',
      href: %r{/searches\?search.*#{case_ref}}
    )
    expect(page).not_to have_govuk_breadcrumb_link(/Case/)
    expect(page).to have_govuk_breadcrumb("Case #{case_ref}", aria_current: true)
  end

  def then_has_defendant_details_breadcrumbs(case_ref, defendant_name)
    expect(page).to have_govuk_breadcrumb_link('Home')
    expect(page).to have_govuk_breadcrumb_link('Search')
    expect(page).to have_govuk_breadcrumb_link("Case #{case_ref}")
    expect(page).not_to have_govuk_breadcrumb_link(defendant_name)
    expect(page).to have_govuk_breadcrumb(defendant_name, aria_current: true)
  end

  def then_has_hearing_details_breadcrumbs(case_ref, hearing_day)
    expect(page).to have_govuk_breadcrumb_link('Home')
    expect(page).to have_govuk_breadcrumb_link('Search')
    expect(page).to have_govuk_breadcrumb_link("Case #{case_ref}")
    expect(page).to have_govuk_breadcrumb("Hearing day #{hearing_day}", aria_current: true)
  end
end
