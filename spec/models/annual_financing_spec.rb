require 'spec_helper'

describe AnnualFinancing do
  it { should belong_to(:arrangement) }

  describe '.funder_countries_to_multilateral_institutions_funding' do
    describe 'reported by funders' do
      it 'should calculate the correct value' do
        country = FactoryGirl.create(:country)
        profile = FactoryGirl.create(:profile, institution: country)
        institution = FactoryGirl.create(:institution, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: institution)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 20)

        AnnualFinancing.funder_countries_to_multilateral_institutions_funding('funders').should eq(20)
      end

      it 'should not consider "incoming" arrangements' do
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming')
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 20)

        AnnualFinancing.funder_countries_to_multilateral_institutions_funding('funders').should eq(0)
      end

      it 'should not consider funder intergovernmental institutions' do
        reporting_institution = FactoryGirl.create(:institution, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
        profile = FactoryGirl.create(:profile, institution: reporting_institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 20)

        AnnualFinancing.funder_countries_to_multilateral_institutions_funding('funders').should eq(0)
      end

      it 'should not consider recipient countries' do
        country = FactoryGirl.create(:country)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', reported_on_institution: country)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 20)

        AnnualFinancing.funder_countries_to_multilateral_institutions_funding('funders').should eq(0)
      end
    end

    describe 'reported by recipients' do
      it 'should calculate the correct value' do
        reporting_institution = FactoryGirl.create(:institution, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
        profile = FactoryGirl.create(:profile, institution: reporting_institution)
        country = FactoryGirl.create(:country)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile, reported_on_institution: country)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 20)

        AnnualFinancing.funder_countries_to_multilateral_institutions_funding('recipients').should eq(20)
      end

      it 'should not consider "outgoing" arrangements' do
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 20)

        AnnualFinancing.funder_countries_to_multilateral_institutions_funding('recipients').should eq(0)
      end

      it 'should not consider funder intergovernmental institutions' do
        reported_on_institution = FactoryGirl.create(:institution, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', reported_on_institution: reported_on_institution)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 20)

        AnnualFinancing.funder_countries_to_multilateral_institutions_funding('recipients').should eq(0)
      end

      it 'should not consider recipient countries' do
        country = FactoryGirl.create(:country)
        profile = FactoryGirl.create(:profile, institution: country)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 20)

        AnnualFinancing.funder_countries_to_multilateral_institutions_funding('recipients').should eq(0)
      end
    end
  end

  describe '.funder_countries_to_redd_plus_countries_funding' do
    describe 'reported by funders' do
      it 'should calculate the correct value' do
        reporting_country = FactoryGirl.create(:country)
        profile = FactoryGirl.create(:profile, institution: reporting_country)
        reported_on_country = FactoryGirl.create(:country)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: reported_on_country)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 20)

        AnnualFinancing.funder_countries_to_redd_plus_countries_funding('funders').should eq(20)
      end

      it 'should not consider "incoming" arrangements' do
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming')
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 20)

        AnnualFinancing.funder_countries_to_redd_plus_countries_funding('funders').should eq(0)
      end

      it 'should not consider funder intergovernmental institutions' do
        reporting_institution = FactoryGirl.create(:institution, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
        profile = FactoryGirl.create(:profile, institution: reporting_institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 20)

        AnnualFinancing.funder_countries_to_redd_plus_countries_funding('funders').should eq(0)
      end

      it 'should not consider recipient intergovernmental institutions' do
        reported_on_institution = FactoryGirl.create(:institution, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', reported_on_institution: reported_on_institution)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 20)

        AnnualFinancing.funder_countries_to_redd_plus_countries_funding('funders').should eq(0)
      end
    end

    describe 'reported by recipients' do
      it 'should calculate the correct value' do
        reporting_country = FactoryGirl.create(:country)
        profile = FactoryGirl.create(:profile, institution: reporting_country)
        reported_on_country = FactoryGirl.create(:country)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile, reported_on_institution: reported_on_country)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 20)

        AnnualFinancing.funder_countries_to_redd_plus_countries_funding('recipients').should eq(20)
      end

      it 'should not consider "outgoing" arrangements' do
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 20)

        AnnualFinancing.funder_countries_to_redd_plus_countries_funding('recipients').should eq(0)
      end

      it 'should not consider funder intergovernmental institutions' do
        reported_on_institution = FactoryGirl.create(:institution, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', reported_on_institution: reported_on_institution)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 20)

        AnnualFinancing.funder_countries_to_redd_plus_countries_funding('recipients').should eq(0)
      end

      it 'should not consider recipient intergovernmental institutions' do
        reporting_institution = FactoryGirl.create(:institution, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
        profile = FactoryGirl.create(:profile, institution: reporting_institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 20)

        AnnualFinancing.funder_countries_to_redd_plus_countries_funding('recipients').should eq(0)
      end
    end
  end

  describe '.multilateral_institutions_to_redd_countries_funding' do
    describe 'reported by funders' do
      it 'should calculate the correct value' do
        institution = FactoryGirl.create(:institution, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
        profile = FactoryGirl.create(:profile, institution: institution)
        country = FactoryGirl.create(:country)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: country)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 20)

        AnnualFinancing.multilateral_institutions_to_redd_countries_funding('funders').should eq(20)
      end

      it 'should not consider "incoming" arrangements' do
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming')
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 20)

        AnnualFinancing.multilateral_institutions_to_redd_countries_funding('funders').should eq(0)
      end

      it 'should not consider funder countries' do
        country = FactoryGirl.create(:country)
        profile = FactoryGirl.create(:profile, institution: country)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 20)

        AnnualFinancing.multilateral_institutions_to_redd_countries_funding('funders').should eq(0)
      end

      it 'should not consider recipient intergovernmental institutions' do
        institution = FactoryGirl.create(:institution, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', reported_on_institution: institution)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 20)

        AnnualFinancing.multilateral_institutions_to_redd_countries_funding('funders').should eq(0)
      end
    end

    describe 'reported by recipients' do
      it 'should calculate the correct value' do
        country = FactoryGirl.create(:country)
        profile = FactoryGirl.create(:profile, institution: country)
        institution = FactoryGirl.create(:institution, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile, reported_on_institution: institution)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 20)

        AnnualFinancing.multilateral_institutions_to_redd_countries_funding('recipients').should eq(20)
      end

      it 'should not consider "outgoing" arrangements' do
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 20)

        AnnualFinancing.multilateral_institutions_to_redd_countries_funding('recipients').should eq(0)
      end

      it 'should not consider funder countries' do
        country = FactoryGirl.create(:country)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', reported_on_institution: country)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 20)

        AnnualFinancing.multilateral_institutions_to_redd_countries_funding('recipients').should eq(0)
      end

      it 'should not consider recipient intergovernmental institutions' do
        institution = FactoryGirl.create(:institution, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
        profile = FactoryGirl.create(:profile, institution: institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 20)

        AnnualFinancing.multilateral_institutions_to_redd_countries_funding('recipients').should eq(0)
      end
    end
  end
  
  describe '.total_funding_per_year_overview' do
    describe 'reported by funders' do
      it 'should return a key-value structure with all the years as keys, and fundings as values' do
        institution = FactoryGirl.create(:institution, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
        profile = FactoryGirl.create(:profile, institution: institution)
        country = FactoryGirl.create(:country)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: country)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, year: 2006, contribution: 10.2)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, year: 2007, contribution: 12.5)

        AnnualFinancing.total_funding_per_year_overview('funders').should eq({non_domestic_flow: 'Outgoing', contributions: {2006 => {non_domestic: 10.2, domestic: 0}, 2007 => {non_domestic: 12.5, domestic: 0}}})
      end

      it 'should not consider incoming arrangements' do
        institution = FactoryGirl.create(:institution, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
        profile = FactoryGirl.create(:profile, institution: institution)
        country = FactoryGirl.create(:country)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile, reported_on_institution: country)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, year: 2006, contribution: 10.2)

        AnnualFinancing.total_funding_per_year_overview('funders')[:contributions].should eq({})
      end

      it 'should consider arrangements with countries as reporters' do
        country = FactoryGirl.create(:country)
        profile = FactoryGirl.create(:profile, institution: country)
        reported_on_country = FactoryGirl.create(:country)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: reported_on_country)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, year: 2006, contribution: 10.2)

        AnnualFinancing.total_funding_per_year_overview('funders')[:contributions].should eq({2006 => {non_domestic: 10.2, domestic: 0}})
      end

      it 'returns ordered years' do
        institution = FactoryGirl.create(:institution, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
        profile = FactoryGirl.create(:profile, institution: institution)
        country = FactoryGirl.create(:country)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: country)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, year: 2007, contribution: 12.5)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, year: 2006, contribution: 10.2)

        # Converting to Array to compare orders of "OrderedHash's"
        AnnualFinancing.total_funding_per_year_overview('funders')[:contributions].to_a.should eq([[2006, {non_domestic: 10.2, domestic: 0}], [2007, {non_domestic: 12.5, domestic: 0}]])
      end

      it 'considers private sector entities' do
        institution = FactoryGirl.create(:institution, institution_type: 'PRIVATE_SECTOR_ENTITY')
        profile = FactoryGirl.create(:profile, institution: institution)
        country = FactoryGirl.create(:country)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: country)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, year: 2006, contribution: 10.2)

        AnnualFinancing.total_funding_per_year_overview('funders').should eq({non_domestic_flow: 'Outgoing', contributions: {2006 => {non_domestic: 10.2, domestic: 0}}})
      end
    end

    describe 'reported by recipients' do
      it 'should return a key-value structure with all the years as keys, and fundings as values' do
        country = FactoryGirl.create(:country)
        profile = FactoryGirl.create(:profile, institution: country)
        institution = FactoryGirl.create(:institution, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile, reported_on_institution: institution)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, year: 2006, contribution: 10.2)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, year: 2007, contribution: 12.5)

        AnnualFinancing.total_funding_per_year_overview('recipients')[:contributions].should eq({2006 => {non_domestic: 10.2, domestic: 0}, 2007 => {non_domestic: 12.5, domestic: 0}})
      end

      it 'should not consider outgoing arrangements' do
        country = FactoryGirl.create(:country)
        profile = FactoryGirl.create(:profile, institution: country)
        institution = FactoryGirl.create(:institution, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: institution)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, year: 2006, contribution: 10.2)

        AnnualFinancing.total_funding_per_year_overview('recipients')[:contributions].should eq({})
      end
      
      it 'should consider arrangements with reported-on countries' do
        country = FactoryGirl.create(:country)
        profile = FactoryGirl.create(:profile, institution: country)
        reported_on_country = FactoryGirl.create(:country)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile, reported_on_institution: reported_on_country)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, year: 2006, contribution: 10.2)

        AnnualFinancing.total_funding_per_year_overview('recipients')[:contributions].should eq({2006 => {non_domestic: 10.2, domestic: 0}})
      end

      it 'returns ordered years' do
        country = FactoryGirl.create(:country)
        profile = FactoryGirl.create(:profile, institution: country)
        institution = FactoryGirl.create(:institution, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile, reported_on_institution: institution)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, year: 2007, contribution: 12.5)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, year: 2006, contribution: 10.2)

        # Converting to Array to compare orders of "OrderedHash's"
        AnnualFinancing.total_funding_per_year_overview('recipients')[:contributions].to_a.should eq([[2006, {non_domestic: 10.2, domestic: 0}], [2007, {non_domestic: 12.5, domestic: 0}]])
      end

      it 'considers private sector entities' do
        country = FactoryGirl.create(:country)
        profile = FactoryGirl.create(:profile, institution: country)
        institution = FactoryGirl.create(:institution, institution_type: 'PRIVATE_SECTOR_ENTITY')
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile, reported_on_institution: institution)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, year: 2006, contribution: 10.2)

        AnnualFinancing.total_funding_per_year_overview('recipients').should eq({non_domestic_flow: 'Incoming', contributions: {2006 => {non_domestic: 10.2, domestic: 0}}})
      end
    end
  end

  describe '.total_funding_per_region_overview' do
    describe 'reported by funders' do
      it 'should return a key-value structure with regions as keys, and fundings as values' do
        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)

        region = FactoryGirl.create(:region, name: 'Africa')
        country = FactoryGirl.create(:country, region: region)

        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: country)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 12.5)

        AnnualFinancing.total_funding_per_region_overview('funders').should eq({non_domestic_flow: 'Outgoing', contributions: {'Africa' => {non_domestic: 12.5, domestic: 0}}})
      end

      it 'should not consider incoming arrangements' do
        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)

        region = FactoryGirl.create(:region, name: 'Africa')
        country = FactoryGirl.create(:country, region: region)

        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile, reported_on_institution: country)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 12.5)

        AnnualFinancing.total_funding_per_region_overview('funders')[:contributions].should eq({})
      end
    end

    describe 'reported by recipients' do
      it 'should return a key-value structure with regions as keys, and fundings as values' do
        region = FactoryGirl.create(:region, name: 'Africa')
        country = FactoryGirl.create(:country, region: region)
        profile = FactoryGirl.create(:profile, institution: country)

        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 12.5)

        AnnualFinancing.total_funding_per_region_overview('recipients').should eq({non_domestic_flow: 'Incoming', contributions: {'Africa' => {non_domestic: 12.5, domestic: 0}}})
      end

      it 'should not consider outgoig arrangements' do
        region = FactoryGirl.create(:region, name: 'Africa')
        country = FactoryGirl.create(:country, region: region)
        profile = FactoryGirl.create(:profile, institution: country)

        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 12.5)

        AnnualFinancing.total_funding_per_region_overview('funders')[:contributions].should eq({})
      end
    end
  end

  describe '.fusion_tables_query' do
    context 'when some arrangement data exists from both perspectives' do
      before(:each) do
        @funding_country = FactoryGirl.create(:country)
        funder_profile = FactoryGirl.create(:profile, institution: @funding_country)
        recipient_institution = FactoryGirl.create(:institution)
        @recipient_country = FactoryGirl.create(:country)
        recipient_profile = FactoryGirl.create(:profile, institution: @recipient_country)

        # Funding_country reports funding recipient institution
        outgoing_arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: funder_profile, reported_on_institution: recipient_institution)
        FactoryGirl.create(:annual_financing, arrangement: outgoing_arrangement, contribution: 20)
        FactoryGirl.create(:annual_financing, arrangement: outgoing_arrangement, contribution: 10)

        # Funding_country reports funding recipient country
        outgoing_arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: funder_profile, reported_on_institution: @recipient_country)
        FactoryGirl.create(:annual_financing, arrangement: outgoing_arrangement, contribution: 90)

        # Recipient_country reports funding itself
        domestic_arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'domestic', profile: recipient_profile, reported_on_institution: @recipient_country)
        FactoryGirl.create(:annual_financing, arrangement: domestic_arrangement, contribution: 15)

        # Recipient_country reports receiving funding from funding_country
        incoming_arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: recipient_profile, reported_on_institution: @funding_country)
        FactoryGirl.create(:annual_financing, arrangement: incoming_arrangement, contribution: 7)
      end

      describe 'querying funding' do
        describe 'reported by funders' do
          it 'returns the sum of outgoing arrangements for the country, ignoring domestic' do
            financing = AnnualFinancing.fusion_tables_query(@funding_country.iso2, 'funded', 'funder')
            financing.to_a.sum(&:contribution).should eq(120)
          end
        end

        describe 'reported by recipients' do
          it 'returns the sum of incoming arrangements from funding country, excluding domestic' do
            financing = AnnualFinancing.fusion_tables_query(@funding_country.iso2, 'funded', 'recipient')
            financing.to_a.sum(&:contribution).should eq(7)
          end
        end
      end

      describe 'querying receiving' do
        describe 'reported by funders' do
          it 'returns the sum of outgoing funding to recipient, including domestic' do
            financing = AnnualFinancing.fusion_tables_query(@recipient_country.iso2, 'received', 'funder')
            financing.to_a.sum(&:contribution).should eq(105)
          end
        end

        describe 'reported by recipients' do
          it 'returns the sum of incoming funding to recipient, including domestic' do
            financing = AnnualFinancing.fusion_tables_query(@recipient_country.iso2, 'received', 'recipient')
            financing.to_a.sum(&:contribution).should eq(22)
          end
        end
      end
    end

    context 'when arrangements reported by countries and institutions exist' do
      before(:each) do
        @reporting_country = FactoryGirl.create(:country)
        @reporting_institution = FactoryGirl.create(:institution)
        @recipient_country = FactoryGirl.create(:country)

        # Country reported data
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing',
                                        profile: FactoryGirl.create(:profile, institution: @reporting_country),
                                        reported_on_institution: @recipient_country)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1)

        # Institution reported data
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing',
                                        profile: FactoryGirl.create(:profile, institution: @reporting_institution),
                                        reported_on_institution: @recipient_country)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 3)
      end

      it 'should ignore the institution reported data' do
        financing = AnnualFinancing.fusion_tables_query(@recipient_country.iso2, 'received', 'funder')
        financing.to_a.sum(&:contribution).should eq(1)
      end
    end

    context 'when funding reported by funders on private entities exist' do
      before(:each) do
        @funder_country = FactoryGirl.create(:country)
        @private_entity = FactoryGirl.create(:institution, institution_type: 'PRIVATE_SECTOR_ENTITY')

        # Country reported data
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing',
                          profile: FactoryGirl.create(:profile, institution: @funder_country),
                          reported_on_institution: @private_entity)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 9)
      end

      it 'should be included when looking at funding reported by funders' do
        financing = AnnualFinancing.fusion_tables_query(@funder_country.iso2, 'funded', 'funder')
        financing.to_a.sum(&:contribution).should eq(9)
      end
    end
    context 'when reciept reported by recipients from private entities exist' do
      before(:each) do
        @recipient_country = FactoryGirl.create(:country)
        @private_entity = FactoryGirl.create(:institution, institution_type: 'PRIVATE_SECTOR_ENTITY')

        # Country reported data
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming',
                          profile: FactoryGirl.create(:profile, institution: @recipient_country),
                          reported_on_institution: @private_entity)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 9)
      end

      it 'should be included when looking at receipt reported by receipients' do
        financing = AnnualFinancing.fusion_tables_query(@recipient_country.iso2, 'received', 'recipient')
        financing.to_a.sum(&:contribution).should eq(9)
      end
    end
    context 'when internal with benefits to REDD+ countries funding reported by funders exist' do
      before(:each) do
        @internal_funder = FactoryGirl.create(:country)

        # Country reported data
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'internal',
                        profile: FactoryGirl.create(:profile, institution: @internal_funder),
                        reported_on_institution: @internal_funder)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 3)
      end

      it 'should be included when looking at funding reported by funders' do
        financing = AnnualFinancing.fusion_tables_query(@internal_funder.iso2, 'funded', 'funder')
        financing.to_a.sum(&:contribution).should eq(3)
      end

      it 'should be excluded when looking at receipt reported by funders' do
        financing = AnnualFinancing.fusion_tables_query(@internal_funder.iso2, 'received', 'funder')
        financing.to_a.sum(&:contribution).should eq(0)
      end
    end
    context 'when unspecified funding reported by funders' do
      before(:each) do
        @funder_country = FactoryGirl.create(:country)
        @other_party = FactoryGirl.create(:institution)

        # Country reported data
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'unspecified',
                          profile: FactoryGirl.create(:profile, institution: @funder_country),
                          reported_on_institution: @other_party)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 9)
      end

      it 'should be included when looking at funding reported by funders' do
        financing = AnnualFinancing.fusion_tables_query(@funder_country.iso2, 'funded', 'funder')
        financing.to_a.sum(&:contribution).should eq(9)
      end
      it 'should be excluded when looking at receipt reported by funders' do
        financing = AnnualFinancing.fusion_tables_query(@other_party.iso2, 'received', 'funder')
        financing.to_a.sum(&:contribution).should eq(0)
      end
    end
    context 'when domestic funding reported' do
      before(:each) do
        @domestic_funder = FactoryGirl.create(:country)

        # Country reported data
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'domestic',
                        profile: FactoryGirl.create(:profile, institution: @domestic_funder),
                        reported_on_institution: @domestic_funder)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 3)
      end

      it 'should be excluded when looking at funding reported by funders' do
        financing = AnnualFinancing.fusion_tables_query(@domestic_funder.iso2, 'funded', 'funder')
        financing.to_a.sum(&:contribution).should eq(0)
      end

      it 'should be included when looking at receipt reported by funders' do
        financing = AnnualFinancing.fusion_tables_query(@domestic_funder.iso2, 'received', 'funder')
        financing.to_a.sum(&:contribution).should eq(3)
      end
    end
  end

  describe '.total_funding_from_and_to' do
    describe 'reported by funders' do
      context 'when 2 countries and 2 institutions exists' do
        before(:each) do
          @country_1 = FactoryGirl.create(:country)
          @country_2 = FactoryGirl.create(:country)
          @institution_1 = FactoryGirl.create(:institution, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
          @institution_2 = FactoryGirl.create(:institution, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
        end

        context 'with 300 country to country funding and 150 country to institution funding' do
          before(:each) do
            profile = FactoryGirl.create(:profile, institution: @country_1)
            arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'outgoing', reported_on_institution: @country_2)
            FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 100)
            FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 200)

            profile = FactoryGirl.create(:profile, institution: @country_1)
            arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'outgoing', reported_on_institution: @institution_1)
            FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 75)
            FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 75)
          end

          it "should return 300 for country to country" do
            AnnualFinancing.total_funding_from_and_to(:country, :country, :funders).should eq(300.0)
          end

          it "should return 150 for country to institution" do
            AnnualFinancing.total_funding_from_and_to(:country, :institution, :funders).should eq(150.0)
          end
        end

        context 'with 345 institution to institution funding and 175 institution to country funding' do
          before(:each) do
            profile = FactoryGirl.create(:profile, institution: @institution_1)
            arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'outgoing', reported_on_institution: @institution_2)
            FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 105)
            FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 240)

            profile = FactoryGirl.create(:profile, institution: @institution_1)
            arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'outgoing', reported_on_institution: @country_1)
            FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 100)
            FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 75)
          end

          it "should return 345 for institution to institution" do
            AnnualFinancing.total_funding_from_and_to(:institution, :institution, :funders).should eq(345.0)
          end

          it "should return 175 for institution to country" do
            AnnualFinancing.total_funding_from_and_to(:institution, :country, :funders).should eq(175.0)
          end
        end
      end
    end
  end

  describe '.total_funding_internal_to_redd_plus_countries' do
    it 'calculates internal funding with benefits to REDD+ countries' do
      institution = FactoryGirl.create(:institution)
      profile = FactoryGirl.create(:profile, institution: institution)
      arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'internal', profile: profile, reported_on_institution: institution)
      FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 10.2)

      AnnualFinancing.total_funding_internal_to_redd_plus_countries.should eq(10.2)
    end
  end
  
  describe '.total_funding_domestic_funding' do
    it 'calculates domestic funding' do
      institution = FactoryGirl.create(:institution)
      profile = FactoryGirl.create(:profile, institution: institution)
      arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'domestic', profile: profile, reported_on_institution: institution)
      FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 10.2)

      AnnualFinancing.total_funding_domestic_funding.should eq(10.2)
    end
  end

  describe '.total_funding_unspecified_flow' do
    it 'calculates funding with unspecified flow' do
      institution = FactoryGirl.create(:institution)
      profile = FactoryGirl.create(:profile, institution: institution)
      arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'unspecified', profile: profile, reported_on_institution: institution)
      FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 10.2)

      AnnualFinancing.total_funding_unspecified_flow.should eq(10.2)
    end
  end

  describe '.total_funding_by_type' do
    describe 'reported by recipients' do
      it 'should return an array of total fundings by type' do
        AnnualFinancing.stub(:total_funding_from_and_to).with(:country, :country, 'recipients').and_return(1)
        AnnualFinancing.stub(:total_funding_from_and_to).with(:country, :institution, 'recipients').and_return(2)
        AnnualFinancing.stub(:total_funding_from_and_to).with(:institution, :institution, 'recipients').and_return(3)
        AnnualFinancing.stub(:total_funding_from_and_to).with(:institution, :country, 'recipients').and_return(4)
        AnnualFinancing.stub(:total_funding_internal_to_redd_plus_countries).and_return(5)
        AnnualFinancing.stub(:total_funding_domestic_funding).and_return(6)

        AnnualFinancing.total_funding_by_type('recipients').should eq((1..6).to_a)
      end
    end

    describe 'reported by funders' do
      it 'should return an array of total fundings by type' do
        AnnualFinancing.stub(:total_funding_from_and_to).with(:country, :country, 'funders').and_return(1)
        AnnualFinancing.stub(:total_funding_from_and_to).with(:country, :institution, 'funders').and_return(2)
        AnnualFinancing.stub(:total_funding_from_and_to).with(:institution, :institution, 'funders').and_return(3)
        AnnualFinancing.stub(:total_funding_from_and_to).with(:institution, :country, 'funders').and_return(4)
        AnnualFinancing.stub(:total_funding_internal_to_redd_plus_countries).and_return(5)
        AnnualFinancing.stub(:total_funding_domestic_funding).and_return(6)
        AnnualFinancing.stub(:total_funding_unspecified_flow).and_return(7)

        AnnualFinancing.total_funding_by_type('funders').should eq((1..7).to_a)
      end
    end
  end
end
