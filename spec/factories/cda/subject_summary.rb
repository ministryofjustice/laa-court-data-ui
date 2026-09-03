# frozen_string_literal: true

FactoryBot.define do
  factory :subject_summary, class: "Cda::SubjectSummary" do
    subject_id { "6c3eded6-a6d6-4156-940d-e3b5f02deb96" }
    date_of_next_hearing { nil }
    defendant_asn { "KQJXI10ZJXCI" }
    defendant_dob { "1994-05-06" }
    defendant_first_name { "Mauricio" }
    defendant_last_name { "Rath" }
    master_defendant_id { nil }
    proceedings_concluded { false }
    organisation_name { nil }
    representation_order { {} }

    offence_summary { [FactoryBot.build(:offence_summary, :with_laa_application)] }
  end
end
