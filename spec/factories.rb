FactoryGirl.define do
  factory :action_category
  factory :annual_financing
  factory :region

  factory :arrangement do
    sequence(:id_feed)
    profile
    association :reported_on_institution, factory: :institution
  end

  factory :institution do
    sequence(:iso2) { |n| "a#{n}" }
    institution_type 'INTERGOVERNMENTAL_INSTITUTION'
  end

  factory :country, class: Institution do
    sequence(:iso2) { |n| "a#{n}" }
    institution_type 'COUNTRY'
  end

  factory :private_sector_entity, class: Institution do
    institution_type 'PRIVATE_SECTOR_ENTITY'
  end

  factory :profile do
    institution
  end
end
