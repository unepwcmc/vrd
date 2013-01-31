require 'spec_helper'

describe Institution do
  it { should have_one(:profile) }
  it { should have_many(:arrangements) }
  it { should have_and_belong_to_many(:beneficiary_arrangements) }

  describe '.funder_countries' do
    it 'should return the funder countries reported by funders' do
      country = FactoryGirl.create(:country)
      profile = FactoryGirl.create(:profile, institution: country)
      FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile)

      Institution.funder_countries.count.should eq(1)
    end

    it 'should not return funder institutions' do
      institution = FactoryGirl.create(:institution)
      profile = FactoryGirl.create(:profile, institution: institution)
      FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile)

      Institution.funder_countries.count.should eq(0)
    end

    it 'should not return countries without an arrangement associated' do
      FactoryGirl.create(:country)

      Institution.funder_countries.count.should eq(0)
    end

    it 'should not return the same country twice' do
      country = FactoryGirl.create(:country)
      profile = FactoryGirl.create(:profile, institution: country)
      FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile)

      # Second profile
      second_profile = FactoryGirl.create(:profile, institution: country)
      FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: second_profile)

      Institution.funder_countries.count.should eq(1)
    end

    it 'should return countries associated with internal with benefits to REDD+ flow arrangements' do
      country = FactoryGirl.create(:country)
      profile = FactoryGirl.create(:profile, institution: country)
      FactoryGirl.create(:arrangement, arrangement_type: 'internal', profile: profile)

      Institution.funder_countries.count.should eq(1)
    end

    it 'should return countries associated with unspecified flow arrangements' do
      country = FactoryGirl.create(:country)
      profile = FactoryGirl.create(:profile, institution: country)
      FactoryGirl.create(:arrangement, arrangement_type: nil, profile: profile)

      Institution.funder_countries.count.should eq(1)
    end

    it 'should NOT return countries associated with incoming flow arrangements' do
      country = FactoryGirl.create(:country)
      profile = FactoryGirl.create(:profile, institution: country)
      FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)

      Institution.funder_countries.count.should eq(0)
    end

    it 'should NOT return countries associated with domestic flow arrangements' do
      country = FactoryGirl.create(:country)
      profile = FactoryGirl.create(:profile, institution: country)
      FactoryGirl.create(:arrangement, arrangement_type: 'domestic', profile: profile)

      Institution.funder_countries.count.should eq(0)
    end
  end

  describe '.redd_plus_countries' do
    it 'should return the REDD+ countries' do
      country = FactoryGirl.create(:country)
      profile = FactoryGirl.create(:profile, institution: country)
      FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)

      Institution.redd_plus_countries.count.should eq(1)
    end

    it 'should not return funder institutions' do
      institution = FactoryGirl.create(:institution)
      profile = FactoryGirl.create(:profile, institution: institution)
      FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)

      Institution.redd_plus_countries.count.should eq(0)
    end

    it 'should not return countries without an arrangement associated' do
      FactoryGirl.create(:country)

      Institution.redd_plus_countries.count.should eq(0)
    end

    it 'should not return the same country twice' do
      country = FactoryGirl.create(:country)
      profile = FactoryGirl.create(:profile, institution: country)
      FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)

      # Second profile
      second_profile = FactoryGirl.create(:profile, institution: country)
      FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: second_profile)

      Institution.redd_plus_countries.count.should eq(1)
    end

    it 'should return countries associated with domestic flow arrangements' do
      country = FactoryGirl.create(:country)
      profile = FactoryGirl.create(:profile, institution: country)
      FactoryGirl.create(:arrangement, arrangement_type: 'domestic', profile: profile)

      Institution.redd_plus_countries.count.should eq(1)
    end

    it 'should NOT return countries associated with outgoing flow arrangements' do
      country = FactoryGirl.create(:country)
      profile = FactoryGirl.create(:profile, institution: country)
      FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile)

      Institution.redd_plus_countries.count.should eq(0)
    end

    it 'should NOT return countries associated with internal with benefits to REDD+ flow arrangements' do
      country = FactoryGirl.create(:country)
      profile = FactoryGirl.create(:profile, institution: country)
      FactoryGirl.create(:arrangement, arrangement_type: 'internal', profile: profile)

      Institution.redd_plus_countries.count.should eq(0)
    end

    it 'should NOT return countries associated with unspecified flow arrangements' do
      country = FactoryGirl.create(:country)
      profile = FactoryGirl.create(:profile, institution: country)
      FactoryGirl.create(:arrangement, arrangement_type: nil, profile: profile)

      Institution.redd_plus_countries.count.should eq(0)
    end
  end

  describe '.overview_institutions' do
    it 'should return funder institutions' do
      institution = FactoryGirl.create(:institution, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
      profile = FactoryGirl.create(:profile, institution: institution)
      FactoryGirl.create(:arrangement, profile: profile)

      Institution.overview_institutions.count.should eq(1)
    end

    it 'should not return funder countries' do
      country = FactoryGirl.create(:country)
      profile = FactoryGirl.create(:profile, institution: country)
      FactoryGirl.create(:arrangement, profile: profile)

      Institution.overview_institutions.count.should eq(0)
    end

    it 'should not return institutions without an arrangement associated' do
      FactoryGirl.create(:institution, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')

      Institution.overview_institutions.count.should eq(0)
    end

    it 'should return funder international_non_governmental_institutions' do
      institution = FactoryGirl.create(:institution, institution_type: 'INTERNATIONAL_NON_GOVERNMENTAL_INSTITUTION')
      profile = FactoryGirl.create(:profile, institution: institution)
      FactoryGirl.create(:arrangement, profile: profile)

      Institution.overview_institutions.count.should eq(1)
    end

    it 'should return funder national_non_governmental_institutions' do
      institution = FactoryGirl.create(:institution, institution_type: 'NATIONAL_NON_GOVERNMENTAL_INSTITUTION')
      profile = FactoryGirl.create(:profile, institution: institution)
      FactoryGirl.create(:arrangement, profile: profile)

      Institution.overview_institutions.count.should eq(1)
    end
  end

  describe '.private_sector_entities' do
    it 'should return funder private sector entities' do
      institution = FactoryGirl.create(:institution, institution_type: 'PRIVATE_SECTOR_ENTITY')
      profile = FactoryGirl.create(:profile, institution: institution)
      FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)

      Institution.private_sector_entities.count.should eq(1)
    end

    it 'should not return institutions without an arrangement associated' do
      FactoryGirl.create(:institution, institution_type: 'PRIVATE_SECTOR_ENTITY')

      Institution.private_sector_entities.count.should eq(0)
    end

    it 'should not return the same country twice' do
      institution = FactoryGirl.create(:institution, institution_type: 'PRIVATE_SECTOR_ENTITY')
      profile = FactoryGirl.create(:profile, institution: institution)
      FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)

      # Second profile
      second_profile = FactoryGirl.create(:profile, institution: institution)
      FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: second_profile)

      Institution.private_sector_entities.count.should eq(1)
    end

    it 'should return institutions associated with incoming flow arrangements' do
      institution = FactoryGirl.create(:institution, institution_type: 'PRIVATE_SECTOR_ENTITY')
      profile = FactoryGirl.create(:profile, institution: institution)
      FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)

      Institution.private_sector_entities.count.should eq(1)
    end

    it 'should return institutions associated with outgoing flow arrangements' do
      institution = FactoryGirl.create(:institution, institution_type: 'PRIVATE_SECTOR_ENTITY')
      profile = FactoryGirl.create(:profile, institution: institution)
      FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile)

      Institution.private_sector_entities.count.should eq(1)
    end

    it 'should NOT return institutions associated with domestic flow arrangements' do
      institution = FactoryGirl.create(:institution, institution_type: 'PRIVATE_SECTOR_ENTITY')
      profile = FactoryGirl.create(:profile, institution: institution)
      FactoryGirl.create(:arrangement, arrangement_type: 'domestic', profile: profile)

      Institution.private_sector_entities.count.should eq(0)
    end

    it 'should NOT return institutions associated with internal with benefits to REDD+ flow arrangements' do
      institution = FactoryGirl.create(:institution, institution_type: 'PRIVATE_SECTOR_ENTITY')
      profile = FactoryGirl.create(:profile, institution: institution)
      FactoryGirl.create(:arrangement, arrangement_type: 'internal', profile: profile)

      Institution.private_sector_entities.count.should eq(0)
    end

    it 'should NOT return institutions associated with unspecified flow arrangements' do
      institution = FactoryGirl.create(:institution, institution_type: 'PRIVATE_SECTOR_ENTITY')
      profile = FactoryGirl.create(:profile, institution: institution)
      FactoryGirl.create(:arrangement, arrangement_type: nil, profile: profile)

      Institution.private_sector_entities.count.should eq(0)
    end
  end

  describe '.overview_arrangements_list_funders' do
    describe 'reported by funders' do
      it 'should return the list of funders' do
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')

        Institution.overview_arrangements_list_funders('funders').count.should eq(1)
      end

      it 'should return the list of reporters' do
        reporter_country = FactoryGirl.create(:country, name: "Reporter country name")
        profile = FactoryGirl.create(:profile, institution: reporter_country)
        reported_on_country = FactoryGirl.create(:country)
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: reported_on_country)

        Institution.overview_arrangements_list_funders('funders').should eq([["Reporter country name", reporter_country.id]])
      end

      context "domestic funding exists" do
        before(:each) do
          @institution = FactoryGirl.create(:country)

          profile = FactoryGirl.create(:profile, institution: @institution)
          arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'domestic', profile: profile)
          arrangement.reported_on_institution = @institution
          arrangement.save
        end

        it "should be included when filtering by the domestic funder" do
          Institution.overview_arrangements_list_funders('funders').should eq([[@institution.name, @institution.id]])
        end
        it "should be included when filtering by the domestic recipient" do
          Institution.overview_arrangements_list_funders('recipients').should eq([[@institution.name, @institution.id]])
        end
      end

      context "unspecified funding exists" do
        before(:each) do
          @institution = FactoryGirl.create(:country)

          profile = FactoryGirl.create(:profile, institution: @institution)
          arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'unspecified', profile: profile)
          arrangement.reported_on_institution = @institution
          arrangement.save
        end

        it "should be included when filtering by reported by funders" do
          Institution.overview_arrangements_list_funders('funders').should eq([[@institution.name, @institution.id]])
        end
        it "should not be included when filtering by reported by recipients" do
          Institution.overview_arrangements_list_funders('recipients').length.should eq(0)
        end
      end
    end

    describe 'reported by recipients' do
      it 'should return the list of funders' do
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming')

        Institution.overview_arrangements_list_funders('recipients').count.should eq(1)
      end

      it 'should return the list of reported on entities' do
        reporter_country = FactoryGirl.create(:country)
        profile = FactoryGirl.create(:profile, institution: reporter_country)
        reported_on_country = FactoryGirl.create(:country, name: "Reported-on country name")
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile, reported_on_institution: reported_on_country)

        Institution.overview_arrangements_list_funders('recipients').should eq([["Reported-on country name", reported_on_country.id]])
      end
    end

    context "domestic funding exists" do
      before(:each) do
        @institution = FactoryGirl.create(:country)

        profile = FactoryGirl.create(:profile, institution: @institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'domestic', profile: profile)
        arrangement.reported_on_institution = @institution
        arrangement.save
      end

      it "should be included when filtering by the domestic funder" do
        Institution.overview_arrangements_list_funders('funders').should eq([[@institution.name, @institution.id]])
      end
      it "should be included when filtering by the domestic recipient" do
        Institution.overview_arrangements_list_funders('recipients').should eq([[@institution.name, @institution.id]])
      end
    end

    context "internal funding exists" do
      before(:each) do
        @institution = FactoryGirl.create(:country)

        profile = FactoryGirl.create(:profile, institution: @institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'internal', profile: profile)
        arrangement.reported_on_institution = @institution
        arrangement.save
      end

      it "should be included when filtering by reported by funders" do
        Institution.overview_arrangements_list_funders('funders').should eq([[@institution.name, @institution.id]])
      end
      it "should be included when filtering by reported by recipients" do
        Institution.overview_arrangements_list_funders('recipients').should eq([[@institution.name, @institution.id]])
      end
    end
  end

  describe '.overview_arrangements_list_recipients' do
    describe 'reported by funders' do
      it 'should return the list of recipients' do
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')

        Institution.overview_arrangements_list_recipients('funders').count.should eq(1)
      end

      it 'should return the list of reported on entities' do
        reporter_country = FactoryGirl.create(:country)
        profile = FactoryGirl.create(:profile, institution: reporter_country)
        reported_on_country = FactoryGirl.create(:country, name: "Reported-on country name")
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: reported_on_country)

        Institution.overview_arrangements_list_recipients('funders').should eq([["Reported-on country name", reported_on_country.id]])
      end

      it 'returns Unspecified when there are unspecified arrangements' do
        FactoryGirl.create(:arrangement, arrangement_type: 'unspecified')

        Institution.overview_arrangements_list_recipients('funders').should eq([["Unspecified or multiple", 'unspecified']])
      end
    end

    describe 'reported by recipients' do
      it 'should return the list of recipients' do
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming')

        Institution.overview_arrangements_list_recipients('recipients').count.should eq(1)
      end

      it 'should return the list of reporters' do
        reporter_country = FactoryGirl.create(:country, name: "Reporter country name")
        profile = FactoryGirl.create(:profile, institution: reporter_country)
        reported_on_country = FactoryGirl.create(:country)
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile, reported_on_institution: reported_on_country)

        Institution.overview_arrangements_list_recipients('recipients').should eq([["Reporter country name", reporter_country.id]])
      end

      it 'doesnt return Unspecified when there are unspecified arrangements' do
        FactoryGirl.create(:arrangement, arrangement_type: 'unspecified')

        Institution.overview_arrangements_list_recipients('recipients').should eq([])
      end
    end

    context "unspecified funding exists" do
      before(:each) do
        @institution = FactoryGirl.create(:country)

        profile = FactoryGirl.create(:profile, institution: @institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'unspecified', profile: profile)
        arrangement.reported_on_institution = @institution
        arrangement.save
      end

      it "should be included when filtering by reported by funders" do
        Institution.overview_arrangements_list_recipients('funders').should eq([['Unspecified or multiple', 'unspecified']])
      end
      it "should not be included when filtering by reported by recipients" do
        Institution.overview_arrangements_list_recipients('recipients').length.should eq(0)
      end
    end

    context "internal funding exists" do
      before(:each) do
        @institution = FactoryGirl.create(:country)

        profile = FactoryGirl.create(:profile, institution: @institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'internal', profile: profile)
        arrangement.reported_on_institution = @institution
        arrangement.save
      end

      it "should be included when filtering by reported by funders" do
        Institution.overview_arrangements_list_recipients('funders').should eq([[@institution.name, @institution.id]])
      end
      it "should be included when filtering by reported by recipients" do
        Institution.overview_arrangements_list_recipients('recipients').should eq([[@institution.name, @institution.id]])
      end
    end
  end

  describe '#incoming_funding' do
    describe 'reported by self' do
      it 'should return total incoming funding' do
        institution = FactoryGirl.create(:institution)

        profile = FactoryGirl.create(:profile, institution: institution)
        reported_on_institution = FactoryGirl.create(:institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile, reported_on_institution: reported_on_institution)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1.2)

        institution.incoming_funding('self').should eq(1.2)
      end
      
      it 'should NOT return outgoing arrangements fundings' do
        institution = FactoryGirl.create(:institution)

        profile = FactoryGirl.create(:profile, institution: institution)
        reported_on_institution = FactoryGirl.create(:institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: reported_on_institution)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1.2)

        institution.incoming_funding('self').should eq(0)
      end
    end

    describe 'reported by others' do
      it 'should return total outgoing funding' do
        reporting_institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: reporting_institution)

        institution = FactoryGirl.create(:institution)

        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: institution)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1.2)

        institution.incoming_funding('others').should eq(1.2)
      end

      it 'should not return incoming arrangements fundings' do
        reporting_institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: reporting_institution)

        institution = FactoryGirl.create(:institution)

        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile, reported_on_institution: institution)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1.2)

        institution.incoming_funding('others').should eq(0)
      end
    end
  end

  describe '#domestic_funding' do
    it 'should return total domestic and internal funding' do
      institution = FactoryGirl.create(:institution)

      profile = FactoryGirl.create(:profile, institution: institution)

      arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'domestic', profile: profile, reported_on_institution: institution)
      FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1.2)

      arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'internal', profile: profile, reported_on_institution: institution)
      FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1.2)

      institution.domestic_funding.should eq(2.4)
    end

    it 'should not return outgoing arrangements fundings' do
      institution = FactoryGirl.create(:institution)

      profile = FactoryGirl.create(:profile, institution: institution)
      arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: institution)
      FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1.2)

      institution.domestic_funding.should eq(0)
    end

    it 'should not return incoming arrangements fundings' do
      institution = FactoryGirl.create(:institution)

      profile = FactoryGirl.create(:profile, institution: institution)
      arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile, reported_on_institution: institution)
      FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1.2)

      institution.domestic_funding.should eq(0)
    end
  end

  describe '#outgoing_funding' do
    describe 'reported by self' do
      it 'should return total outgoing funding' do
        institution = FactoryGirl.create(:institution)

        profile = FactoryGirl.create(:profile, institution: institution)
        reported_on_institution = FactoryGirl.create(:institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: reported_on_institution)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1.2)

        institution.outgoing_funding('self').should eq(1.2)
      end

      it 'should NOT return incoming arrangements fundings' do
        institution = FactoryGirl.create(:institution)

        profile = FactoryGirl.create(:profile, institution: institution)
        reported_on_institution = FactoryGirl.create(:institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile, reported_on_institution: reported_on_institution)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1.2)

        institution.outgoing_funding('self').should eq(0)
      end
    end

    describe 'reported by others' do
      it 'should return total outgoing funding' do
        reporting_institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: reporting_institution)

        institution = FactoryGirl.create(:institution)

        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile, reported_on_institution: institution)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1.2)

        institution.outgoing_funding('others').should eq(1.2)
      end

      it 'should not return incoming arrangements fundings' do
        reporting_institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: reporting_institution)

        institution = FactoryGirl.create(:institution)

        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: institution)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1.2)

        institution.outgoing_funding('others').should eq(0)
      end
    end
  end

  describe '#unspecified_recipients_funding' do
    describe 'reported by self' do
      it 'returns the unspecified recipients funding amount' do
        institution = FactoryGirl.create(:institution)

        profile = FactoryGirl.create(:profile, institution: institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'unspecified', profile: profile)
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1.2)

        institution.unspecified_recipients_funding('self').should eq(1.2)
      end
    end

    describe 'reported by others' do
      it 'returns zero' do
        institution = FactoryGirl.create(:institution)
        institution.unspecified_recipients_funding('others').should eq(0)
      end
    end
  end

  describe '#arrangement_totals_by_institution' do
    describe 'reported by self' do
      context 'when funding exists from and to countries' do
        before(:each) do
          @subject_country = FactoryGirl.create(:country)
          @funder_country = FactoryGirl.create(:country)
          @recipient_country = FactoryGirl.create(:country)

          # Incoming funding
          profile = FactoryGirl.create(:profile, institution: @subject_country)
          arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'incoming', reported_on_institution: @funder_country)
          FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1)
          FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 2.2)

          # Outgoing funding
          profile = FactoryGirl.create(:profile, institution: @subject_country)
          arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'outgoing', reported_on_institution: @recipient_country)
          FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 4)

          # Domestic
          profile = FactoryGirl.create(:profile, institution: @subject_country)
          arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'domestic', reported_on_institution: @subject_country)
          FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 4)
        end

        it 'should return the correct sums receiving - funding for each country' do
          results = @subject_country.arrangement_totals_by_institution 'self'
          results[@funder_country.iso2].should eq(-3.2)
          results[@recipient_country.iso2].should eq(4)
          results[@subject_country.iso2].should eq(nil)
        end
      end
    end

    describe 'reported by others' do
      context 'when funding exists from and to countries' do
        before(:each) do
          @subject_country = FactoryGirl.create(:country)
          @funder_country = FactoryGirl.create(:country)
          @recipient_country = FactoryGirl.create(:country)

          profile = FactoryGirl.create(:profile, institution: @funder_country)
          arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'outgoing', reported_on_institution: @subject_country)
          FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1)
          FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 6)

          profile = FactoryGirl.create(:profile, institution: @recipient_country)
          arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'incoming', reported_on_institution: @subject_country)
          FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 8)

          arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'outgoing', reported_on_institution: @subject_country)
          FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 0.3)
        end

        it 'should return the correct sums receiving - funding for each country' do
          results = @subject_country.arrangement_totals_by_institution 'others'
          results[@funder_country.iso2].should eq(-7)
          results[@recipient_country.iso2].should eq(7.7)
        end
      end
    end
  end
  
  describe '#arrangements_list_funders' do
    describe 'reported by self' do
      it 'should return the list of funders' do
        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)

        reported_on_institution = FactoryGirl.create(:institution, name: "Reported on institution name")
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile, reported_on_institution: reported_on_institution)

        institution.arrangements_list_funders('self').should eq([["Reported on institution name", reported_on_institution.id]])
      end

      it 'should not return duplicates' do
        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)

        reported_on_institution = FactoryGirl.create(:institution, name: "Reported on institution name")

        FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile, reported_on_institution: reported_on_institution)

        second_profile = FactoryGirl.create(:profile, institution: institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: second_profile, reported_on_institution: reported_on_institution)

        institution.arrangements_list_funders('self').should eq([["Reported on institution name", reported_on_institution.id]])
      end

      it 'should return self when reporting outgoing arrangement' do
        institution = FactoryGirl.create(:institution, name: "Reporting institution name")
        profile = FactoryGirl.create(:profile, institution: institution)

        reported_on_institution = FactoryGirl.create(:institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: reported_on_institution)

        institution.arrangements_list_funders('self').should eq([["Reporting institution name", institution.id]])
      end

      context "domestic funding exists" do
        before(:each) do
          @institution = FactoryGirl.create(:institution)

          profile = FactoryGirl.create(:profile, institution: @institution)
          arrangement = FactoryGirl.create(:arrangement, profile: profile, reported_on_institution: @institution, arrangement_type: 'domestic')
          arrangement.reported_on_institution = @institution
          arrangement.save
        end

        it "should be included in the results" do
          result = @institution.arrangements_list_funders('self')
          result.length.should eq(1)
        end
      end

      context "unspecified funding exists" do
        before(:each) do
          @institution = FactoryGirl.create(:institution)

          profile = FactoryGirl.create(:profile, institution: @institution)
          arrangement = FactoryGirl.create(:arrangement, profile: profile, reported_on_institution: @institution, arrangement_type: 'unspecified')
          arrangement.reported_on_institution = @institution
          arrangement.save
        end

        it "the reporting institution should be in the funder list" do
          result = @institution.arrangements_list_funders('self')
          result.should eq([[@institution.name, @institution.id]])
        end
      end
    end

    describe 'reported by others' do
      it 'should return the list of funders' do
        reporting_institution = FactoryGirl.create(:institution, name: "Reporting institution name")
        profile = FactoryGirl.create(:profile, institution: reporting_institution)

        institution = FactoryGirl.create(:institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: institution)

        institution.arrangements_list_funders('others').should eq([["Reporting institution name", reporting_institution.id]])
      end

      it 'should return self when reporting incoming arrangement' do
        reporting_institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: reporting_institution)

        institution = FactoryGirl.create(:institution, name: "Reported on institution name")
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile, reported_on_institution: institution)

        institution.arrangements_list_funders('others').should eq([["Reported on institution name", institution.id]])
      end

      context "domestic funding exists" do
        before(:each) do
          @institution = FactoryGirl.create(:institution)

          profile = FactoryGirl.create(:profile, institution: @institution)
          arrangement = FactoryGirl.create(:arrangement, profile: profile, reported_on_institution: @institution, arrangement_type: 'domestic')
          arrangement.reported_on_institution = @institution
          arrangement.save
        end

        it "should not be included in the results" do
          result = @institution.arrangements_list_funders('others')
          result.length.should eq(0)
        end
      end

      context "unspecified funding exists" do
        before(:each) do
          @institution = FactoryGirl.create(:institution)

          profile = FactoryGirl.create(:profile, institution: @institution)
          arrangement = FactoryGirl.create(:arrangement, profile: profile, reported_on_institution: @institution, arrangement_type: 'unspecified')
          arrangement.reported_on_institution = @institution
          arrangement.save
        end

        it "should not be included in the results" do
          result = @institution.arrangements_list_funders('others')
          result.length.should eq(0)
        end
      end
    end
  end
  
  describe '#arrangements_list_recipients' do
    describe 'reported by self' do
      it 'should return the list of recipients' do
        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)

        reported_on_institution = FactoryGirl.create(:institution, name: "Reported on institution name")
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: reported_on_institution)

        institution.arrangements_list_recipients('self').should eq([["Reported on institution name", reported_on_institution.id]])
      end

      it 'should not return duplicates' do
        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)

        reported_on_institution = FactoryGirl.create(:institution, name: "Reported on institution name")

        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: reported_on_institution)

        second_profile = FactoryGirl.create(:profile, institution: institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: second_profile, reported_on_institution: reported_on_institution)

        institution.arrangements_list_recipients('self').should eq([["Reported on institution name", reported_on_institution.id]])
      end

      it 'returns self when reporting incoming arrangement' do
        institution = FactoryGirl.create(:institution, name: "Reporting institution name")
        profile = FactoryGirl.create(:profile, institution: institution)

        reported_on_institution = FactoryGirl.create(:institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile, reported_on_institution: reported_on_institution)

        institution.arrangements_list_recipients('self').should eq([["Reporting institution name", institution.id]])
      end

      it 'returns self when reporting internal arrangement' do
        institution = FactoryGirl.create(:institution, name: "Reporting institution name")
        profile = FactoryGirl.create(:profile, institution: institution)

        reported_on_institution = FactoryGirl.create(:institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'internal', profile: profile, reported_on_institution: reported_on_institution)

        institution.arrangements_list_recipients('self').should eq([["Reporting institution name", institution.id]])
      end

      it 'returns Unspecified when there are unspecified arrangements' do
        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)

        reported_on_institution = FactoryGirl.create(:institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'unspecified', profile: profile, reported_on_institution: reported_on_institution)

        institution.arrangements_list_recipients('self').should eq([["Unspecified or multiple", 'unspecified']])
      end

      context "domestic funding exists" do
        before(:each) do
          @institution = FactoryGirl.create(:institution)

          profile = FactoryGirl.create(:profile, institution: @institution)
          arrangement = FactoryGirl.create(:arrangement, profile: profile, reported_on_institution: @institution, arrangement_type: 'domestic')
          arrangement.reported_on_institution = @institution
          arrangement.save
          FactoryGirl.create(:annual_financing, contribution: 10, arrangement: arrangement)
        end

        it "should be included in the results" do
          result = @institution.arrangements_list_recipients('self')
          result.length.should eq(1)
        end
      end
    end

    describe 'reported by others' do
      it 'should return the list of recipients' do
        reporting_institution = FactoryGirl.create(:institution, name: "Reporting institution name")
        profile = FactoryGirl.create(:profile, institution: reporting_institution)

        institution = FactoryGirl.create(:institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile, reported_on_institution: institution)

        institution.arrangements_list_recipients('others').should eq([["Reporting institution name", reporting_institution.id]])
      end

      it 'should return self when reporting outgoing arrangement' do
        reporting_institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: reporting_institution)

        institution = FactoryGirl.create(:institution, name: "Reported on institution name")
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: institution)

        institution.arrangements_list_recipients('others').should eq([["Reported on institution name", institution.id]])
      end

      context "unspecified funding exists" do
        before(:each) do
          @institution = FactoryGirl.create(:institution)

          profile = FactoryGirl.create(:profile, institution: @institution)
          arrangement = FactoryGirl.create(:arrangement, profile: profile, reported_on_institution: @institution, arrangement_type: 'unspecified')
          arrangement.reported_on_institution = @institution
          arrangement.save
        end

        it "should not be included in the results" do
          result = @institution.arrangements_list_recipients('others')
          result.length.should eq(0)
        end
      end

      context "domestic funding exists" do
        before(:each) do
          @institution = FactoryGirl.create(:institution)

          profile = FactoryGirl.create(:profile, institution: @institution)
          arrangement = FactoryGirl.create(:arrangement, profile: profile, reported_on_institution: @institution, arrangement_type: 'domestic')
          arrangement.reported_on_institution = @institution
          arrangement.save
          FactoryGirl.create(:annual_financing, contribution: 10, arrangement: arrangement)
        end

        it "should not be included in the results" do
          result = @institution.arrangements_list_recipients('others')
          result.length.should eq(0)
        end
      end
    end
  end

  describe '#arrangement_totals_by_year' do
    context 'reported by self' do
      context 'funding and receipt exists cross years' do
        before(:each) do
          @subject_country = FactoryGirl.create(:country)
          @funder_country = FactoryGirl.create(:country)
          @recipient_institution = FactoryGirl.create(:institution)

          # 2010
          ## Funding
          profile = FactoryGirl.create(:profile, institution: @subject_country)
          arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'outgoing', reported_on_institution: @recipient_institution)
          FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1, year: 2010)
          FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 3, year: 2010)
          ## Receipt
          profile = FactoryGirl.create(:profile, institution: @subject_country)
          arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'incoming', reported_on_institution: @funder_country)
          FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 2, year: 2010)

          # 2011
          ## Funding
          profile = FactoryGirl.create(:profile, institution: @subject_country)
          arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'outgoing', reported_on_institution: @recipient_institution)
          FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1, year: 2011)

          # 2012
          ## Receipt
          profile = FactoryGirl.create(:profile, institution: @subject_country)
          arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'incoming', reported_on_institution: @funder_country)
          FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1.2, year: 2012)
        end

        it 'should return correct arrangement sums for years' do
          result = @subject_country.arrangement_totals_by_year 'self'
          result['series']['2010']['outgoing'].should eq(4)
          result['series']['2010']['incoming'].should eq(2)
          result['series']['2011']['outgoing'].should eq(1)
          result['series']['2011']['incoming'].should eq(nil)
          result['series']['2012']['outgoing'].should eq(nil)
          result['series']['2012']['incoming'].should eq(1.2)
        end
      end

      context "domestic and internal arrangements exist" do
        before(:each) do
          @subject_country = FactoryGirl.create(:country)

          profile = FactoryGirl.create(:profile, institution: @subject_country)
          arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'domestic', reported_on_institution: @subject_country)
          FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1, year: 2010)

          profile = FactoryGirl.create(:profile, institution: @subject_country)
          arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'internal', reported_on_institution: @subject_country)
          FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1.5, year: 2010)
        end

        it "should be included in results" do
          result = @subject_country.arrangement_totals_by_year 'self'
          result['series']['2010']['internal_domestic_unspecified'].should eq(2.5)
        end
      end
    end

    context 'reported by others' do
      context 'funding and receipt exists cross years' do
        before(:each) do
          @subject_country = FactoryGirl.create(:country)
          @funder_country = FactoryGirl.create(:country)
          @recipient_institution = FactoryGirl.create(:institution)

          # 2010
          ## Funding
          profile = FactoryGirl.create(:profile, institution: @recipient_institution)
          arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'incoming', reported_on_institution: @subject_country)
          FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1, year: 2010)
          FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 3, year: 2010)

          profile = FactoryGirl.create(:profile, institution: @recipient_institution)
          arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'incoming', reported_on_institution: @subject_country)
          FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1, year: 2010)

          ## Receipt
          profile = FactoryGirl.create(:profile, institution: @funder_country)
          arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'outgoing', reported_on_institution: @subject_country)
          FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 2, year: 2010)

          # 2011
          ## Funding
          profile = FactoryGirl.create(:profile, institution: @recipient_institution)
          arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'incoming', reported_on_institution: @subject_country)
          FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1, year: 2011)

          # 2012
          ## Receipt
          profile = FactoryGirl.create(:profile, institution: @funder_country)
          arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'outgoing', reported_on_institution: @subject_country)
          FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1.2, year: 2012)
        end

        it 'should return correct arrangement sums for years' do
          result = @subject_country.arrangement_totals_by_year 'others'
          result['series']['2010']['outgoing'].should eq(5)
          result['series']['2010']['incoming'].should eq(2)
          result['series']['2011']['outgoing'].should eq(1)
          result['series']['2011']['incoming'].should eq(nil)
          result['series']['2012']['outgoing'].should eq(nil)
          result['series']['2012']['incoming'].should eq(1.2)
        end
      end

      context "domestic and internal arrangements exist" do
        before(:each) do
          @subject_country = FactoryGirl.create(:country)

          profile = FactoryGirl.create(:profile, institution: @subject_country)
          arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'domestic', reported_on_institution: @subject_country)
          FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1, year: 2010)

          profile = FactoryGirl.create(:profile, institution: @subject_country)
          arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'internal', reported_on_institution: @subject_country)
          FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1, year: 2010)
        end

        it "should be ignored" do
          result = @subject_country.arrangement_totals_by_year 'others'
          result['series'].length.should eq(0)
        end
      end
    end
  end

  describe '#arrangements_list' do
    describe 'reported by self' do
      it 'should return list of arrangements' do
        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)
        reported_on_institution = FactoryGirl.create(:institution)
        FactoryGirl.create(:arrangement, profile: profile, reported_on_institution: reported_on_institution)

        institution.arrangements_list('self')[:models].count.should eq(1)
      end

      it 'should not return arrangements not associated with the institution' do
        institution = FactoryGirl.create(:institution)

        reporting_institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: reporting_institution)
        reported_on_institution = FactoryGirl.create(:institution)
        FactoryGirl.create(:arrangement, profile: profile, reported_on_institution: reported_on_institution)

        institution.arrangements_list('self')[:models].count.should eq(0)
      end

      it 'should return institution/country id' do
        institution = FactoryGirl.create(:institution)
        institution.arrangements_list('self')[:institution_id].should eq(institution.id)
      end

      it 'should return reported_by value' do
        institution = FactoryGirl.create(:institution)
        institution.arrangements_list('self')[:reported_by].should eq('self')
      end

      it 'should return current_page as 1' do
        institution = FactoryGirl.create(:institution)
        institution.arrangements_list('self')[:current_page].should eq(1)
      end

      it 'should return the total number of pages and 20 arrangements per page' do
        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)

        21.times {
          FactoryGirl.create(:arrangement, profile: profile)
        }

        institution.arrangements_list('self')[:pages].should eq(2)
        institution.arrangements_list('self')[:models].count.should eq(20)
      end

      it 'should not return arrangements without self entity as the reporter' do
        institution = FactoryGirl.create(:institution)

        second_institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: second_institution)
        FactoryGirl.create(:arrangement, profile: profile)

        institution.arrangements_list('self')[:models].count.should eq(0)
      end

      it 'should return the total number of arrangements as both total and maximum' do
        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)
        FactoryGirl.create(:arrangement, profile: profile)

        institution.arrangements_list('self')[:total].should eq(1)
        institution.arrangements_list('self')[:maximum].should eq(1)
      end

      it 'should return smallest year of financings' do
        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)
        arrangement = FactoryGirl.create(:arrangement, profile: profile)
        FactoryGirl.create(:annual_financing, year: 2007, arrangement: arrangement)
        institution.arrangements_list('self')[:timespan][:min].should eq(2007)
      end

      it 'should return highest year of financings that have an arrangement assigned' do
        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)
        arrangement = FactoryGirl.create(:arrangement, profile: profile)
        FactoryGirl.create(:annual_financing, year: 2014, arrangement: arrangement)
        institution.arrangements_list('self')[:timespan][:max].should eq(2014)
      end

      it 'returns the rounded smallest financing of an arrangement' do
        institution = FactoryGirl.create(:institution)

        profile = FactoryGirl.create(:profile, institution: institution)
        arrangement = FactoryGirl.create(:arrangement, profile: profile)
        FactoryGirl.create(:annual_financing, contribution: 10.2, arrangement: arrangement)
        FactoryGirl.create(:annual_financing, contribution: 10.2, arrangement: arrangement)

        second_profile = FactoryGirl.create(:profile, institution: institution)
        second_arrangement = FactoryGirl.create(:arrangement, profile: second_profile)
        FactoryGirl.create(:annual_financing, contribution: 1.1, arrangement: second_arrangement)
        FactoryGirl.create(:annual_financing, contribution: 1.1, arrangement: second_arrangement)

        institution.arrangements_list('self')[:amount][:min].should eq(2)
      end

      it 'should return ceiled highest financing of an arrangement' do
        institution = FactoryGirl.create(:institution)

        profile = FactoryGirl.create(:profile, institution: institution)
        arrangement = FactoryGirl.create(:arrangement, profile: profile)
        FactoryGirl.create(:annual_financing, contribution: 10.2, arrangement: arrangement)
        FactoryGirl.create(:annual_financing, contribution: 10.2, arrangement: arrangement)

        second_profile = FactoryGirl.create(:profile, institution: institution)
        second_arrangement = FactoryGirl.create(:arrangement, profile: profile)
        FactoryGirl.create(:annual_financing, contribution: 1.1, arrangement: second_arrangement)
        FactoryGirl.create(:annual_financing, contribution: 1.1, arrangement: second_arrangement)

        institution.arrangements_list('self')[:amount][:max].should eq(21)
      end

      it 'should return the total financing for all the arrangements' do
        institution = FactoryGirl.create(:institution)

        profile = FactoryGirl.create(:profile, institution: institution)
        arrangement = FactoryGirl.create(:arrangement, profile: profile)
        FactoryGirl.create(:annual_financing, contribution: 10, arrangement: arrangement)
        FactoryGirl.create(:annual_financing, contribution: 10, arrangement: arrangement)

        second_profile = FactoryGirl.create(:profile, institution: institution)
        second_arrangement = FactoryGirl.create(:arrangement, profile: second_profile)
        FactoryGirl.create(:annual_financing, contribution: 1, arrangement: second_arrangement)
        FactoryGirl.create(:annual_financing, contribution: 1, arrangement: second_arrangement)

        institution.arrangements_list('self')[:total_amount].should eq(22)
      end
    end

    describe 'reported by others' do
      it 'should return list of arrangements' do
        reporting_institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: reporting_institution)
        institution = FactoryGirl.create(:institution)
        FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'outgoing', reported_on_institution: institution)

        institution.arrangements_list('others')[:models].count.should eq(1)
      end

      it 'should not return arrangements not associated with the institution' do
        institution = FactoryGirl.create(:institution)

        reporting_institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: reporting_institution)
        reported_on_institution = FactoryGirl.create(:institution)
        FactoryGirl.create(:arrangement, profile: profile, reported_on_institution: reported_on_institution)

        institution.arrangements_list('others')[:models].count.should eq(0)
      end

      it 'should return reported_by value' do
        institution = FactoryGirl.create(:institution)
        institution.arrangements_list('others')[:reported_by].should eq('others')
      end

      it 'should return current_page as 1' do
        institution = FactoryGirl.create(:institution)
        institution.arrangements_list('others')[:current_page].should eq(1)
      end

      it 'does not return internal/domestic arrangements' do
        reporting_institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: reporting_institution)

        institution = FactoryGirl.create(:institution)
        FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'domestic', reported_on_institution: institution)
        FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'internal', reported_on_institution: institution)

        institution.arrangements_list('others')[:models].count.should eq(0)
      end
    end
  end

  describe '#funder_countries' do
    it 'should return funder countries reporting' do
      country = FactoryGirl.create(:country)
      profile = FactoryGirl.create(:profile, institution: country)
      institution = FactoryGirl.create(:institution)
      FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: institution)

      institution.funder_countries.count.should eq(1)
    end
  end

  describe '#redd_plus_countries' do
    it 'should return REDD+ countries reporting' do
      country = FactoryGirl.create(:country)
      profile = FactoryGirl.create(:profile, institution: country)
      institution = FactoryGirl.create(:institution)
      FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile, reported_on_institution: institution)

      institution.redd_plus_countries.count.should eq(1)
    end
  end

  describe '#funder_institutions' do
    it 'should return funder institutions reporting' do
      reporting_institution = FactoryGirl.create(:institution)
      profile = FactoryGirl.create(:profile, institution: reporting_institution)

      institution = FactoryGirl.create(:institution)
      FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: institution)

      second_reporting_institution = FactoryGirl.create(:institution)
      second_profile = FactoryGirl.create(:profile, institution: second_reporting_institution)

      FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: second_profile, reported_on_institution: institution)

      institution.funder_institutions.count.should eq(2)
    end
  end

  describe '#private_sector_entities' do
    it 'should return funder institutions reporting' do
      reporting_entity = FactoryGirl.create(:private_sector_entity)
      profile = FactoryGirl.create(:profile, institution: reporting_entity)

      institution = FactoryGirl.create(:institution)
      FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: institution)

      second_reporting_entity = FactoryGirl.create(:private_sector_entity)
      second_profile = FactoryGirl.create(:profile, institution: second_reporting_entity)

      FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: second_profile, reported_on_institution: institution)

      institution.private_sector_entities.count.should eq(2)
    end
  end

  describe '#self_has_reported' do
    it 'should return if self has reported any arrangements' do
      institution = FactoryGirl.create(:institution)
      profile = FactoryGirl.create(:profile, institution: institution)
      FactoryGirl.create(:arrangement, profile: profile)

      institution.self_has_reported.should be_true
    end
    
    it 'should return false if not' do
      institution = FactoryGirl.create(:institution)
      institution.self_has_reported.should be_false
    end
  end

  describe '#total_arrangements' do
    it 'should return number of total arrangements for the institution' do
      institution = FactoryGirl.create(:institution)

      profile = FactoryGirl.create(:profile, institution: institution)
      FactoryGirl.create(:arrangement, profile: profile)

      FactoryGirl.create(:arrangement, reported_on_institution: institution)

      institution.total_arrangements.count.should eq(2)
    end
  end

  describe '#arrangement_counts_by_action_category' do
    context 'when some arrangement data exists from both perspectives' do
      before(:each) do
        @subject_country = FactoryGirl.create(:country)
        @another_country = FactoryGirl.create(:country)
        @institution = FactoryGirl.create(:institution)

        # Self reported arrangements data
        profile = FactoryGirl.create(:profile, institution: @subject_country)
        arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'outgoing', reported_on_institution: @institution)
        FactoryGirl.create(:action_category, name: 'category_1', arrangement: arrangement)

        profile = FactoryGirl.create(:profile, institution: @subject_country)
        arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'internal', reported_on_institution: @another_country)
        FactoryGirl.create(:action_category, name: 'category_1', arrangement: arrangement)

        arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'internal', reported_on_institution: @another_country)
        FactoryGirl.create(:action_category, name: 'category_2', arrangement: arrangement)

        profile = FactoryGirl.create(:profile, institution: @subject_country)
        arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'domestic', reported_on_institution: @subject_country)
        FactoryGirl.create(:action_category, name: 'category_2', arrangement: arrangement)

        # Receiving perspective data
        profile = FactoryGirl.create(:profile, institution: @institution)
        arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'incoming', reported_on_institution: @subject_country)
        FactoryGirl.create(:action_category, name: 'category_2', arrangement: arrangement)

        arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'incoming', reported_on_institution: @subject_country)
        FactoryGirl.create(:action_category, name: 'category_3', arrangement: arrangement)

        arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'unspecified', reported_on_institution: @subject_country)
        FactoryGirl.create(:action_category, name: 'category_3', arrangement: arrangement)

        arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'domestic', reported_on_institution: @subject_country)
        FactoryGirl.create(:action_category, name: 'category_3', arrangement: arrangement)

        # Unrelated data (should be ignored)
        profile = FactoryGirl.create(:profile, institution: @another_country)
        arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'outgoing', reported_on_institution: @institution)
        FactoryGirl.create(:action_category, name: 'category_2', arrangement: arrangement)
      end

      describe 'from perspective of self' do
        before(:each) do
          @counts = @subject_country.arrangement_counts_by_action_category('self')
        end

        it 'should return funder correct data for subject country' do
          @counts['Category 1'][:outgoing].should eq(2)
          @counts['Category 1'][:incoming].should eq(0)
          @counts['Category 2'][:outgoing].should eq(1)
          @counts['Category 2'][:incoming].should eq(1)
        end
      end

      describe 'from perspective of others' do
        before(:each) do
          @counts = @subject_country.arrangement_counts_by_action_category('others')
        end

        it 'should return recipient correct data' do
          @counts['Category 2'][:outgoing].should eq(1)
          @counts['Category 2'][:incoming].should eq(0)
          @counts['Category 3'][:outgoing].should eq(1)
          @counts['Category 3'][:incoming].should eq(0)
        end
      end
    end
  end

  describe "#funders_and_recipients" do
    context "funders exist from both perspectives" do
      before(:each) do
        @institution = FactoryGirl.create(:country, id_feed: 1)
        @funder_1 = FactoryGirl.create(:country, id_feed: 2)
        @funder_2 = FactoryGirl.create(:institution, id_feed: 3)

        profile = FactoryGirl.create(:profile, institution: @funder_1)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile)
        arrangement.reported_on_institution = @institution
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1)

        profile = FactoryGirl.create(:profile, institution: @institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)
        arrangement.reported_on_institution = @funder_2
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1)
      end
      it "should return everything" do
        @institution.funders_and_recipients.map(&:id_feed).should eq([@institution.id_feed, @funder_1.id_feed, @funder_2.id_feed])
      end
    end
    context "recipients exist from both perspectives" do
      before(:each) do
        @institution = FactoryGirl.create(:country, id_feed: 1)
        @recipient_1 = FactoryGirl.create(:country, id_feed: 2)
        @recipient_2 = FactoryGirl.create(:institution, id_feed: 3)

        profile = FactoryGirl.create(:profile, institution: @recipient_1)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)
        arrangement.reported_on_institution = @institution
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1)

        profile = FactoryGirl.create(:profile, institution: @institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile)
        arrangement.reported_on_institution = @recipient_2
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1)
      end
      it "should return everything" do
        @institution.funders_and_recipients.map(&:id_feed).should eq([@institution.id_feed, @recipient_1.id_feed, @recipient_2.id_feed])
      end
    end
    context "non-typical (unspecied, domestic, internal) funding exists" do
      before(:each) do
        @institution = FactoryGirl.create(:country, id_feed: 1)
        @recipient_1 = FactoryGirl.create(:country, id_feed: 2)
        @recipient_2 = FactoryGirl.create(:institution, id_feed: 3)

        profile = FactoryGirl.create(:profile, institution: @institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'domestic', profile: profile)
        arrangement.reported_on_institution = @institution
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1)

        profile = FactoryGirl.create(:profile, institution: @institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'internal', profile: profile)
        arrangement.reported_on_institution = @institution
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1)

        profile = FactoryGirl.create(:profile, institution: @institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'unspecified', profile: profile)
        arrangement.reported_on_institution = @institution
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1)
      end
      it "should be ignored" do
        @institution.funders_and_recipients.length.should eq(1)
      end
    end
    context "indirect receiving exists" do
      before(:each) do
        @institution = FactoryGirl.create(:country, id_feed: 1)
        @igo = FactoryGirl.create(:institution, id_feed: 2, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
        @indirect_funder = FactoryGirl.create(:country, id_feed: 3)

        profile = FactoryGirl.create(:profile, institution: @institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)
        arrangement.reported_on_institution = @igo
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1)

        profile = FactoryGirl.create(:profile, institution: @indirect_funder)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile)
        arrangement.reported_on_institution = @igo
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1)
      end
      it "the indirect funder should be included in results" do
        @institution.funders_and_recipients.map(&:id_feed).should eq([@institution.id_feed, @igo.id_feed, @indirect_funder.id_feed])
      end
    end
    context "indirect funding exists" do
      before(:each) do
        @institution = FactoryGirl.create(:country, id_feed: 1)
        @igo = FactoryGirl.create(:institution, id_feed: 2, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
        @indirect_recipient = FactoryGirl.create(:country, id_feed: 3)

        profile = FactoryGirl.create(:profile, institution: @institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile)
        arrangement.reported_on_institution = @igo
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1)

        profile = FactoryGirl.create(:profile, institution: @igo)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile)
        arrangement.reported_on_institution = @indirect_recipient
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1)
      end
      it "the indirect recipient should be included in results" do
        @institution.funders_and_recipients.map(&:id_feed).should eq([@institution.id_feed, @igo.id_feed, @indirect_recipient.id_feed])
      end
    end
    context "other indirect recipients exists alongside @institution" do
      before(:each) do
        @institution = FactoryGirl.create(:country, id_feed: 1)
        @igo = FactoryGirl.create(:institution, id_feed: 2, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
        @indirect_funder = FactoryGirl.create(:country, id_feed: 3)
        @another_indirect_recipient = FactoryGirl.create(:country, id_feed: 4)

        profile = FactoryGirl.create(:profile, institution: @igo)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile)
        arrangement.reported_on_institution = @institution
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1)

        profile = FactoryGirl.create(:profile, institution: @another_indirect_recipient)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)
        arrangement.reported_on_institution = @igo
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1)

        profile = FactoryGirl.create(:profile, institution: @igo)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)
        arrangement.reported_on_institution = @indirect_funder
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 2)
      end
      it "should return the indirect funder, but not the other indirect recipients" do
        @institution.funders_and_recipients.map(&:id_feed).sort.should eq([
                       @institution.id_feed,
                       @igo.id_feed,
                       @indirect_funder.id_feed
                     ])
      end
    end
    context "funding with 0 contribution exists" do
      before(:each) do
        @institution = FactoryGirl.create(:country, id_feed: 1)
        @igo = FactoryGirl.create(:institution, id_feed: 2, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')

        profile = FactoryGirl.create(:profile, institution: @institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)
        arrangement.reported_on_institution = @igo
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 0)

        profile = FactoryGirl.create(:profile, institution: @institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)
        arrangement.reported_on_institution = @igo
        arrangement.save
      end
      it "should be ignored" do
        @institution.funders_and_recipients.map(&:id_feed).should eq([@institution.id_feed])
      end
    end
  end

  describe "#arrangement_totals_array" do
    context "funding exist from both perspectives" do
      before(:each) do
        @institution = FactoryGirl.create(:country, id_feed: 1)
        @funder_1 = FactoryGirl.create(:country, id_feed: 2)

        profile = FactoryGirl.create(:profile, institution: @funder_1)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile)
        arrangement.reported_on_institution = @institution
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1.2)

        profile = FactoryGirl.create(:profile, institution: @institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)
        arrangement.reported_on_institution = @funder_1
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 3.5)
      end
      it "should be summed correctly" do
        @institution.arrangement_totals_array.should eq([
                       {from_id_feed: @institution.id_feed, to_id_feed: @funder_1.id_feed, total: -4.7},
                       {from_id_feed: @institution.id_feed, to_id_feed: @institution.id_feed, total: 4.7}
                     ])
      end
    end
    context "funding and recieving exists from both perspectives" do
      before(:each) do
        @institution = FactoryGirl.create(:country, id_feed: 1)
        @funder = FactoryGirl.create(:country, id_feed: 2)
        @recipient = FactoryGirl.create(:institution, id_feed: 3)

        profile = FactoryGirl.create(:profile, institution: @funder)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile)
        arrangement.reported_on_institution = @institution
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1)

        profile = FactoryGirl.create(:profile, institution: @institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile)
        arrangement.reported_on_institution = @recipient
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 2)
      end
      it "should be summed correctly" do
        @institution.arrangement_totals_array.should eq([
                       {from_id_feed: @institution.id_feed, to_id_feed: @recipient.id_feed, total: 2},
                       {from_id_feed: @institution.id_feed, to_id_feed: @funder.id_feed, total: -1},
                       {from_id_feed: @institution.id_feed, to_id_feed: @institution.id_feed, total: -1}
                     ])
      end
    end
    context "non-typical (unspecied, domestic, internal) funding exists" do
      before(:each) do
        @institution = FactoryGirl.create(:country, id_feed: 1)
        @recipient_1 = FactoryGirl.create(:country, id_feed: 2)
        @recipient_2 = FactoryGirl.create(:institution, id_feed: 3)

        profile = FactoryGirl.create(:profile, institution: @institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'domestic', profile: profile)
        arrangement.reported_on_institution = @institution
        arrangement.save

        profile = FactoryGirl.create(:profile, institution: @institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'internal', profile: profile)
        arrangement.reported_on_institution = @institution
        arrangement.save

        profile = FactoryGirl.create(:profile, institution: @institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'unspecified', profile: profile)
        arrangement.reported_on_institution = @institution
        arrangement.save
      end
      it "should be ignored" do
        @institution.arrangement_totals_array.should eq([{from_id_feed: @institution.id_feed, to_id_feed: @institution.id_feed, total: 0}])
      end
    end
    context "indirect receiving exists" do
      before(:each) do
        @institution = FactoryGirl.create(:country, id_feed: 1)
        @igo = FactoryGirl.create(:institution, id_feed: 2, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
        @indirect_funder = FactoryGirl.create(:country, id_feed: 3)

        profile = FactoryGirl.create(:profile, institution: @institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)
        arrangement.reported_on_institution = @igo
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1)

        profile = FactoryGirl.create(:profile, institution: @igo)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)
        arrangement.reported_on_institution = @indirect_funder
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 2)
      end
      it "the indirect funder should be included in results when requested" do
        @institution.arrangement_totals_array(true).should eq([
                       {from_id_feed: @institution.id_feed, to_id_feed: @igo.id_feed, total: -1},
                       {from_id_feed: @institution.id_feed, to_id_feed: @institution.id_feed, total: 1},
                       {from_id_feed: @igo.id_feed, to_id_feed: @indirect_funder.id_feed, total: -2}
                     ])
      end
    end
    context "many indirect recipients exists" do
      before(:each) do
        @institution = FactoryGirl.create(:country, id_feed: 1)
        @igo = FactoryGirl.create(:institution, id_feed: 2, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
        @indirect_funder = FactoryGirl.create(:country, id_feed: 3)
        @another_indirect_recipient = FactoryGirl.create(:country, id_feed: 4)

        profile = FactoryGirl.create(:profile, institution: @institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)
        arrangement.reported_on_institution = @igo
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1)

        profile = FactoryGirl.create(:profile, institution: @another_indirect_recipient)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)
        arrangement.reported_on_institution = @igo
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1)

        profile = FactoryGirl.create(:profile, institution: @igo)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)
        arrangement.reported_on_institution = @indirect_funder
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 2)
      end
      it "should only return the @institutions receiving" do
        @institution.arrangement_totals_array(true).should eq([
                       {from_id_feed: @institution.id_feed, to_id_feed: @igo.id_feed, total: -1},
                       {from_id_feed: @institution.id_feed, to_id_feed: @institution.id_feed, total: 1},
                       {from_id_feed: @igo.id_feed, to_id_feed: @indirect_funder.id_feed, total: -2}
                     ])
      end
    end

    context "entities both fund and receive from each other" do
      before(:each) do
        @institution = FactoryGirl.create(:country, id_feed: 1)
        @igo = FactoryGirl.create(:institution, id_feed: 2, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')

        profile = FactoryGirl.create(:profile, institution: @institution)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)
        arrangement.reported_on_institution = @igo
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1)

        profile = FactoryGirl.create(:profile, institution: @igo)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)
        arrangement.reported_on_institution = @institution
        arrangement.save
        FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 2)
      end
      it "should return the sums of funding and receiving seperately (not summed)" do
        @institution.arrangement_totals_array.should eq([
                       {from_id_feed: @institution.id_feed, to_id_feed: @igo.id_feed, total: 2},
                       {from_id_feed: @institution.id_feed, to_id_feed: @igo.id_feed, total: -1},
                       {from_id_feed: @institution.id_feed, to_id_feed: @institution.id_feed, total: -1}
                     ])
      end
    end
  end

  context "Pakistan funds GEF 1.6, but GEF funds Pakistan back 0 (therefore not at all). Canada funds GEF but is not an indirect funder to Pakistan" do
    before(:each) do
      @pakistan = FactoryGirl.create(:country, id_feed: 1)
      @gef = FactoryGirl.create(:institution, id_feed: 2, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')
      @canada = FactoryGirl.create(:country, id_feed: 3)

      profile = FactoryGirl.create(:profile, institution: @gef)
      arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)
      arrangement.reported_on_institution = @pakistan
      arrangement.save
      FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 1.6)

      profile = FactoryGirl.create(:profile, institution: @pakistan)
      arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)
      arrangement.reported_on_institution = @gef
      arrangement.save
      FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 0)
      FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 0)

      profile = FactoryGirl.create(:profile, institution: @gef)
      arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)
      arrangement.reported_on_institution = @canada
      arrangement.save
      FactoryGirl.create(:annual_financing, arrangement: arrangement, contribution: 51.8)
    end

    it "@pakistan.funders_and_recipients(true) should return GEF but not Canada" do
      fnr_ids = @pakistan.funders_and_recipients.map(&:id_feed).should eq([@pakistan.id_feed, @gef.id_feed])
    end
    it "@pakistan.arrangement_totals_array should return only the GEF funding total" do
      @pakistan.arrangement_totals_array(true).should eq([
                 {from_id_feed: @pakistan.id_feed, to_id_feed: @gef.id_feed, total: 1.6},
                 {from_id_feed: @pakistan.id_feed, to_id_feed: @pakistan.id_feed, total: -1.6}
                ])
    end
    it "recipient.funders_and_recipients and recipient.arrangement_totals_array should return the same institutions" do
      fnr_ids = @pakistan.funders_and_recipients(true).map(&:id_feed).sort
      fnr_ids.should eq(@pakistan.arrangement_totals_array(true).map{|t|t[:to_id_feed]}.sort)
    end
  end
end
