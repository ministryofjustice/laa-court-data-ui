class CreateOffences < ActiveRecord::Migration[6.1]
  def change
    create_table :defendants do |t|
      t.string :name
      t.string :date_of_birth
      t.string :national_insurance_number
      t.string :arrest_summons_number
      t.string :maat_reference
      t.timestamps
    end
  
    create_table :offences do |t|
      t.belongs_to :defendant
      t.string :title
      t.string :legislation
      t.string :mode_of_trial
      t.string :mode_of_trial_reasons
      t.string :pleas
      t.timestamps
    end
  end
end
