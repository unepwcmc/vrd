require 'spec_helper'

describe Arrangement do
  it { should belong_to(:profile) }
  it { should belong_to(:reported_on_institution) }
  it { should have_one(:reporting_institution) }
  it { should have_many(:annual_financings) }
  it { should have_many(:action_categories) }

  describe '.overview_redd_plus_arrangements' do
    it 'should return the total number of arrangements' do
      FactoryGirl.create(:arrangement)
      Arrangement.overview_redd_plus_arrangements.should eq(1)
    end
  end

  describe '.funding' do
    context 'when some funding and receiving arrangement data exists' do
      before(:each) do
        @funding_1 = FactoryGirl.create(:arrangement, arrangement_type: 'internal')
        @funding_2 = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')
        @receipt_1 = FactoryGirl.create(:arrangement, arrangement_type: 'incoming')
        @receipt_2 = FactoryGirl.create(:arrangement, arrangement_type: 'domestic')
      end

      it 'should return all the funding data' do
        funding_types = ['outgoing', 'internal']
        the_funding = Arrangement.funding

        the_funding.each do |a|
          funding_types.should include(a.arrangement_type)
        end

        the_funding.count.should eq(2)
      end
    end
  end

  describe '.counts_by_action_category' do
    context 'when some arrangement data exists from both perspectives' do
      before(:each) do
        @country = FactoryGirl.create(:country)
        @institution = FactoryGirl.create(:institution, institution_type: 'INTERGOVERNMENTAL_INSTITUTION')

        # Funding perspective data
        profile = FactoryGirl.create(:profile, institution: @country)
        arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'outgoing', reported_on_institution: @institution)
        FactoryGirl.create(:action_category, name: 'category_1', arrangement: arrangement)

        profile = FactoryGirl.create(:profile, institution: @country)
        arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'internal', reported_on_institution: @country)
        FactoryGirl.create(:action_category, name: 'category_1', arrangement: arrangement)

        arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'internal', reported_on_institution: @country)
        FactoryGirl.create(:action_category, name: 'category_2', arrangement: arrangement)

        # Receiving perspective data
        profile = FactoryGirl.create(:profile, institution: @institution)
        arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'incoming', reported_on_institution: @country)
        FactoryGirl.create(:action_category, name: 'category_2', arrangement: arrangement)

        arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'incoming', reported_on_institution: @country)
        FactoryGirl.create(:action_category, name: 'category_3', arrangement: arrangement)

        profile = FactoryGirl.create(:profile, institution: @country)
        arrangement = FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'domestic', reported_on_institution: @country)
        FactoryGirl.create(:action_category, name: 'category_3', arrangement: arrangement)
      end

      describe 'from perspective of funders' do
        before(:each) do
          @counts = Arrangement.counts_by_action_category('funders')
        end

        it 'should return funder correct data' do
          @counts['Category 1'].should eq(2)
          @counts['Category 2'].should eq(1)
        end

        it 'should not return recipient data' do
          @counts['Category 3'].should_not eq(2)
        end
      end

      describe 'from perspective of recipients' do
        before(:each) do
          @counts = Arrangement.counts_by_action_category('recipients')
        end

        it 'should return recipient correct data' do
          @counts['Category 2'].should eq(1)
          @counts['Category 3'].should eq(2)
        end

        it 'should not return funder data' do
          @counts['Category 1'].should_not eq(2)
        end
      end
    end
  end
  
  describe '.overview_list' do
    describe 'reported by funders' do
      it 'should return reported_by value' do
        Arrangement.overview_list('funders')[:reported_by].should eq('funders')
      end

      it 'should return current_page as 1' do
        Arrangement.overview_list('funders')[:current_page].should eq(1)
      end

      it 'should return the total number of pages and 20 arrangements per page' do
        21.times { FactoryGirl.create(:arrangement, arrangement_type: 'outgoing') }

        Arrangement.overview_list('funders')[:pages].should eq(2)
        Arrangement.overview_list('funders')[:models].count.should eq(20)
      end

      it 'should return arrangements with outgoing flow' do
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')

        Arrangement.overview_list('funders')[:models].count.should eq(1)
      end

      it 'should return arrangements with internal with benefits to REDD+ flow' do
        FactoryGirl.create(:arrangement, arrangement_type: 'internal')

        Arrangement.overview_list('funders')[:models].count.should eq(1)
      end

      it 'should return arrangements with unspecified flow' do
        FactoryGirl.create(:arrangement, arrangement_type: 'unspecified')

        Arrangement.overview_list('funders')[:models].count.should eq(1)
      end

      it 'should not return arrangements with incoming flow' do
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming')

        Arrangement.overview_list('funders')[:models].count.should eq(0)
      end

      it 'should return the total number of arrangements as both total and maximum' do
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')

        Arrangement.overview_list('funders')[:total].should eq(1)
        Arrangement.overview_list('funders')[:maximum].should eq(1)
      end

      it 'should return smallest year of financings' do
        FactoryGirl.create(:annual_financing, year: 2007)
        Arrangement.overview_list('funders')[:timespan][:min].should eq(2007)
      end

      it 'should return highest year of financings that have an arrangement assigned' do
        FactoryGirl.create(:annual_financing, year: 2014)
        Arrangement.overview_list('funders')[:timespan][:max].should eq(2014)
      end

      it 'should return smallest financing of an arrangement' do
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')
        FactoryGirl.create(:annual_financing, contribution: 10.2, arrangement: arrangement)
        FactoryGirl.create(:annual_financing, contribution: 10.2, arrangement: arrangement)

        second_arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')
        FactoryGirl.create(:annual_financing, contribution: 1.1, arrangement: second_arrangement)
        FactoryGirl.create(:annual_financing, contribution: 1.1, arrangement: second_arrangement)

        Arrangement.overview_list('funders')[:amount][:min].should eq(2.2)
      end

      it 'should return ceiled highest financing of an arrangement' do
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')
        FactoryGirl.create(:annual_financing, contribution: 10.2, arrangement: arrangement)
        FactoryGirl.create(:annual_financing, contribution: 10.2, arrangement: arrangement)

        second_arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')
        FactoryGirl.create(:annual_financing, contribution: 1.1, arrangement: second_arrangement)
        FactoryGirl.create(:annual_financing, contribution: 1.1, arrangement: second_arrangement)

        Arrangement.overview_list('funders')[:amount][:max].should eq(21)
      end

      it 'should not return the min financing for financings without an arrangements' do
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')
        FactoryGirl.create(:annual_financing, contribution: 10.2, arrangement: arrangement)

        FactoryGirl.create(:annual_financing, contribution: 1.1, arrangement: nil)

        Arrangement.overview_list('funders')[:amount][:min].should eq(10.2)
      end

      it 'should not return the max financing for financings without an arrangements' do
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')
        FactoryGirl.create(:annual_financing, contribution: 2, arrangement: arrangement)

        FactoryGirl.create(:annual_financing, contribution: 10.2, arrangement: nil)

        Arrangement.overview_list('funders')[:amount][:max].should eq(2)
      end

      it 'should return the total financing for all the arrangements' do
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')
        FactoryGirl.create(:annual_financing, contribution: 10, arrangement: arrangement)
        FactoryGirl.create(:annual_financing, contribution: 10, arrangement: arrangement)

        second_arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')
        FactoryGirl.create(:annual_financing, contribution: 1, arrangement: second_arrangement)
        FactoryGirl.create(:annual_financing, contribution: 1, arrangement: second_arrangement)

        Arrangement.overview_list('funders')[:total_amount].should eq(22)
      end

      it 'should not return the total financing for financings without arrangements' do
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')
        FactoryGirl.create(:annual_financing, contribution: 10.2, arrangement: arrangement)

        FactoryGirl.create(:annual_financing, contribution: 1.1, arrangement: nil)

        Arrangement.overview_list('funders')[:total_amount].should eq(10.2)
      end

      it 'should not return the annual financing in the total value for invalid arrangements' do
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')
        FactoryGirl.create(:annual_financing, contribution: 10.2, arrangement: arrangement)

        second_arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'incoming')
        FactoryGirl.create(:annual_financing, contribution: 1.1, arrangement: second_arrangement)

        Arrangement.overview_list('funders')[:total_amount].should eq(10.2)
      end
    end

    describe 'reported by recipients' do
      it 'should return reported_by value' do
        Arrangement.overview_list('recipients')[:reported_by].should eq('recipients')
      end

      it 'should return current_page as 1' do
        Arrangement.overview_list('recipients')[:current_page].should eq(1)
      end
      
      it 'should return the total number of pages' do
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming')

        Arrangement.overview_list('recipients')[:pages].should eq(1)
      end
      
      it 'should return the total number of pages and 20 arrangements per page' do
        21.times { FactoryGirl.create(:arrangement, arrangement_type: 'incoming') }

        Arrangement.overview_list('recipients')[:pages].should eq(2)
        Arrangement.overview_list('recipients')[:models].count.should eq(20)
      end

      it 'should return the total number of arrangements as both total and maximum' do
        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)

        second_institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: second_institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile)

        Arrangement.overview_list('recipients')[:total].should eq(1)
        Arrangement.overview_list('recipients')[:maximum].should eq(2)
      end

      it 'should not return arrangements with outgoing flow' do
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')

        Arrangement.overview_list('recipients')[:models].count.should eq(0)
      end

      it 'should not return arrangements with unspecified flow' do
        FactoryGirl.create(:arrangement, arrangement_type: 'unspecified')

        Arrangement.overview_list('recipients')[:models].count.should eq(0)
      end

      it 'should return arrangements with incoming flow' do
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming')

        Arrangement.overview_list('recipients')[:models].count.should eq(1)
      end

      it 'should return arrangements with domestic flow' do
        FactoryGirl.create(:arrangement, arrangement_type: 'domestic')

        Arrangement.overview_list('recipients')[:models].count.should eq(1)
      end
    end

    context "a domestic arrangements exists" do
      before(:each) do
        FactoryGirl.create(:arrangement, arrangement_type: 'domestic')
      end
      it 'should be returned in the results, regardless of perspective' do
        Arrangement.overview_list('funders')[:models].count.should eq(1)
        Arrangement.overview_list('recipients')[:models].count.should eq(1)
      end
    end
    context "an internal arrangements exists" do
      before(:each) do
        FactoryGirl.create(:arrangement, arrangement_type: 'internal')
      end
      it 'should be returned in the results, regardless of perspective' do
        Arrangement.overview_list('funders')[:models].count.should eq(1)
        Arrangement.overview_list('recipients')[:models].count.should eq(1)
      end
    end
  end

  describe '.search' do
    describe 'reported by funders' do
      it 'should return institution/country id when it is sent on the params' do
        institution = FactoryGirl.create(:institution)

        Arrangement.search({reported_by: 'funders', institution_id: institution.id})[:institution_id].should eq(institution.id)
      end

      it 'should return reported_by value' do
        Arrangement.search({reported_by: 'funders'})[:reported_by].should eq('funders')
      end

      it 'should return current_page value' do
        Arrangement.search({reported_by: 'funders', page: 1})[:current_page].should eq(1)
        Arrangement.search({reported_by: 'funders', page: 2})[:current_page].should eq(2)
      end

      it 'should return the total number of pages and 20 arrangements per page' do
        21.times { FactoryGirl.create(:arrangement, arrangement_type: 'outgoing') }

        Arrangement.search({reported_by: 'funders'})[:pages].should eq(2)
        Arrangement.search({reported_by: 'funders'})[:models].count.should eq(20)
      end

      it 'should return arrangements with outgoing flow' do
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')

        Arrangement.search({reported_by: 'funders'})[:models].count.should eq(1)
      end

      it 'should return arrangements with unspecified flow' do
        FactoryGirl.create(:arrangement, arrangement_type: 'unspecified')

        Arrangement.search({reported_by: 'funders'})[:models].count.should eq(1)
      end

      it 'should not return arrangements with incoming flow' do
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming')

        Arrangement.search({reported_by: 'funders'})[:models].count.should eq(0)
      end

      it 'should return the total and maximum number of arrangements' do
        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile)

        second_institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: second_institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile)

        Arrangement.search({reported_by: 'funders', funder: institution.id})[:total].should eq(1)
        Arrangement.search({reported_by: 'funders', funder: institution.id})[:maximum].should eq(2)
      end

      it 'should return filtered by funder assessments' do
        country = FactoryGirl.create(:country)
        profile = FactoryGirl.create(:profile, institution: country)
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile)

        # Arrangement that should not be returned
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')

        Arrangement.search({reported_by: 'funders', funder: country.id})[:models].count.should eq(1)
      end

      it 'should return filtered by recipient assessments' do
        country = FactoryGirl.create(:country)
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', reported_on_institution: country)

        # Arrangement that should not be returned
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')

        Arrangement.search({reported_by: 'funders', recipient: country.id})[:models].count.should eq(1)
      end

      it 'should return filtered by period_from assessemnts' do
        FactoryGirl.create(:arrangement, period_to: 2006)
        Arrangement.search({reported_by: 'funders', period_from: 2007})[:models].count.should eq(0)
      end

      it 'should return filtered by period_to assessemnts' do
        FactoryGirl.create(:arrangement, period_from: 2008)
        Arrangement.search({reported_by: 'funders', period_to: 2007})[:models].count.should eq(0)
      end

      it 'should return filtered by amount_from assessemnts' do
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')
        FactoryGirl.create(:annual_financing, contribution: 2, arrangement: arrangement)
        Arrangement.search({reported_by: 'funders', amount_from: 10})[:models].count.should eq(0)
      end

      it 'should return filtered by amount_to assessemnts' do
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')
        FactoryGirl.create(:annual_financing, contribution: 12, arrangement: arrangement)
        Arrangement.search({reported_by: 'funders', amount_to: 10})[:models].count.should eq(0)
      end

      it 'should return the total financing for all the arrangements' do
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')
        FactoryGirl.create(:annual_financing, contribution: 10.2, arrangement: arrangement)
        FactoryGirl.create(:annual_financing, contribution: 10.2, arrangement: arrangement)

        second_arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')
        FactoryGirl.create(:annual_financing, contribution: 1.1, arrangement: second_arrangement)
        FactoryGirl.create(:annual_financing, contribution: 1.1, arrangement: second_arrangement)

        Arrangement.search({reported_by: 'funders'})[:total_amount].should eq(22.6)
      end

      it 'should not return the total financing for financings without arrangements' do
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')
        FactoryGirl.create(:annual_financing, contribution: 10.2, arrangement: arrangement)

        FactoryGirl.create(:annual_financing, contribution: 1.1, arrangement: nil)

        Arrangement.search({reported_by: 'funders'})[:total_amount].should eq(10.2)
      end

      it 'should not return the annual financing in the total value for arrangements out of selection' do
        country = FactoryGirl.create(:country)
        profile = FactoryGirl.create(:profile, institution: country)
        arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile)
        FactoryGirl.create(:annual_financing, contribution: 10.2, arrangement: arrangement)

        second_arrangement = FactoryGirl.create(:arrangement)
        FactoryGirl.create(:annual_financing, contribution: 1.1, arrangement: second_arrangement)

        Arrangement.search({reported_by: 'funders', funder: country.id})[:total_amount].should eq(10.2)
      end

      it 'returns filtered by unspecified recipient arrangements' do
        FactoryGirl.create(:arrangement, arrangement_type: 'unspecified')

        Arrangement.search({reported_by: 'funders', recipient: 'unspecified'})[:models].count.should eq(1)
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
          Arrangement.search({reported_by: 'funders', funder: @institution.id})[:models].count.should eq(1)
        end
        it "should be included when filtering by the domestic recipient" do
          Arrangement.search({reported_by: 'funders', recipient: @institution.id})[:models].count.should eq(1)
        end
        it "should be included when filtering by the domestic recipient and funder" do
          Arrangement.search({reported_by: 'funders',
                             recipient: @institution.id,
                             funder: @institution.id
          })[:models].count.should eq(1)
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
        it "should be included when filtering by the domestic funder" do
          Arrangement.search({reported_by: 'funders', funder: @institution.id})[:models].count.should eq(1)
        end
        it "should be included when filtering by the domestic recipient" do
          Arrangement.search({reported_by: 'funders', recipient: @institution.id})[:models].count.should eq(1)
        end
        it "should be included when filtering by the domestic recipient and funder" do
          Arrangement.search({reported_by: 'funders',
                             recipient: @institution.id,
                             funder: @institution.id
          })[:models].count.should eq(1)
        end
      end
    end

    describe 'reported by recipients' do
      it 'should return reported_by value' do
        Arrangement.search({reported_by: 'recipients'})[:reported_by].should eq('recipients')
      end

      it 'should return current_page value' do
        Arrangement.search({reported_by: 'recipients', page: 1})[:current_page].should eq(1)
        Arrangement.search({reported_by: 'recipients', page: 2})[:current_page].should eq(2)
      end
      
      it 'should return the total number of pages' do
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming')

        Arrangement.search({reported_by: 'recipients'})[:pages].should eq(1)
      end
      
      it 'should return the total number of pages and 20 arrangements per page' do
        21.times { FactoryGirl.create(:arrangement, arrangement_type: 'incoming') }

        Arrangement.search({reported_by: 'recipients'})[:pages].should eq(2)
        Arrangement.search({reported_by: 'recipients'})[:models].count.should eq(20)
      end

      it 'should return the total and maximum number of arrangements' do
        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)

        second_institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: second_institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)

        Arrangement.search({reported_by: 'recipients', recipient: institution.id})[:total].should eq(1)
        Arrangement.search({reported_by: 'recipients', recipient: institution.id})[:maximum].should eq(2)
      end

      it 'should not return arrangements with outgoing flow' do
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')

        Arrangement.search({reported_by: 'recipients'})[:models].count.should eq(0)
      end

      it 'should not return arrangements with unspecified flow' do
        FactoryGirl.create(:arrangement, arrangement_type: 'unspecified')

        Arrangement.search({reported_by: 'recipients'})[:models].count.should eq(0)
      end

      it 'should return arrangements with incoming flow' do
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming')

        Arrangement.search({reported_by: 'recipients'})[:models].count.should eq(1)
      end

      it 'should return arrangements with domestic flow' do
        FactoryGirl.create(:arrangement, arrangement_type: 'domestic')

        Arrangement.search({reported_by: 'recipients'})[:models].count.should eq(1)
      end

      it 'should return filtered by funder assessments' do
        country = FactoryGirl.create(:country)
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming', reported_on_institution: country)

        # Arrangement that should not be returned
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming')

        Arrangement.search({reported_by: 'recipients', funder: country.id})[:models].count.should eq(1)
      end

      it 'should return filtered by recipient assessments' do
        country = FactoryGirl.create(:country)
        profile = FactoryGirl.create(:profile, institution: country)
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)

        # Arrangement that should not be returned
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming')

        Arrangement.search({reported_by: 'recipients', recipient: country.id})[:models].count.should eq(1)
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
          Arrangement.search({reported_by: 'recipients', funder: @institution.id})[:models].count.should eq(1)
        end
        it "should be included when filtering by the domestic recipient" do
          Arrangement.search({reported_by: 'recipients', recipient: @institution.id})[:models].count.should eq(1)
        end
        it "should be included when filtering by the domestic recipient and funder" do
          Arrangement.search({reported_by: 'recipients',
                             recipient: @institution.id,
                             funder: @institution.id
          })[:models].count.should eq(1)
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
        it "should be included when filtering by the domestic funder" do
          Arrangement.search({reported_by: 'recipients', funder: @institution.id})[:models].count.should eq(1)
        end
        it "should be included when filtering by the domestic recipient" do
          Arrangement.search({reported_by: 'recipients', recipient: @institution.id})[:models].count.should eq(1)
        end
        it "should be included when filtering by the domestic recipient and funder" do
          Arrangement.search({reported_by: 'recipients',
                             recipient: @institution.id,
                             funder: @institution.id
          })[:models].count.should eq(1)
        end
      end
    end
    
    describe 'reported by self' do
      it 'should filter by institution/country' do
        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)
        FactoryGirl.create(:arrangement, profile: profile)

        # Arrangement that should not be returned
        second_institution = FactoryGirl.create(:institution)
        second_profile = FactoryGirl.create(:profile, institution: second_institution)
        FactoryGirl.create(:arrangement, profile: second_profile)

        Arrangement.search({reported_by: 'self', institution_id: institution.id})[:models].count.should eq(1)
      end

      it 'returns filtered by funder assessments' do
        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)

        reported_on_institution = FactoryGirl.create(:institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile, reported_on_institution: reported_on_institution)

        # Arrangement that should not be returned
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)

        Arrangement.search({reported_by: 'self', institution_id: institution.id, funder: reported_on_institution.id})[:models].count.should eq(1)
      end

      it 'returns filtered by funder assessments when self is funder' do
        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)

        reported_on_institution = FactoryGirl.create(:institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: reported_on_institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'internal', profile: profile, reported_on_institution: reported_on_institution)

        Arrangement.search({reported_by: 'self', institution_id: institution.id, funder: institution.id})[:models].count.should eq(2)
      end

      it 'returns filtered by recipient assessments' do
        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)

        reported_on_institution = FactoryGirl.create(:institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: reported_on_institution)

        # Arrangement that should not be returned
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile)

        Arrangement.search({reported_by: 'self', institution_id: institution.id, recipient: reported_on_institution.id})[:models].count.should eq(1)
      end

      it 'returns filtered by recipient assessments when self is recipient' do
        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)

        reported_on_institution = FactoryGirl.create(:institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile, reported_on_institution: reported_on_institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'internal', profile: profile, reported_on_institution: reported_on_institution)

        Arrangement.search({reported_by: 'self', institution_id: institution.id, recipient: institution.id})[:models].count.should eq(2)
      end

      it 'returns filtered by unspecified recipient arrangements' do
        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)

        reported_on_institution = FactoryGirl.create(:institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'unspecified', profile: profile, reported_on_institution: reported_on_institution)

        Arrangement.search({reported_by: 'self', institution_id: institution.id, recipient: 'unspecified'})[:models].count.should eq(1)
      end

      it 'does not return arrangements with self as recipient when filtering by other entity' do
        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)

        FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile)

        filter_institution = FactoryGirl.create(:institution)

        Arrangement.search({reported_by: 'self', institution_id: institution.id, recipient: filter_institution.id})[:models].count.should eq(0)
      end

      it 'does not return arrangements with self as funder when filtering by other entity' do
        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)

        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile)

        filter_institution = FactoryGirl.create(:institution)

        Arrangement.search({reported_by: 'self', institution_id: institution.id, funder: filter_institution.id})[:models].count.should eq(0)
      end
      
      it 'returns arrangements with unspecified recipient when filtering by self funder' do
        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)

        FactoryGirl.create(:arrangement, arrangement_type: 'unspecified', profile: profile, reported_on_institution: institution)

        Arrangement.search({reported_by: 'self', institution_id: institution.id, funder: institution.id, recipient: 'unspecified'})[:models].count.should eq(1)
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
          Arrangement.search({reported_by: 'self', institution_id: @institution.id, funder: @institution.id})[:models].count.should eq(1)
        end
        it "should be included when filtering by the domestic recipient" do
          Arrangement.search({reported_by: 'self', institution_id: @institution.id, recipient: @institution.id})[:models].count.should eq(1)
        end
        it "should be included when filtering by the domestic recipient and funder" do
          Arrangement.search({reported_by: 'self', institution_id: @institution.id,
                             recipient: @institution.id,
                             funder: @institution.id
          })[:models].count.should eq(1)
        end
      end
    end

    describe 'reported by others' do
      it 'should filter by institution/country' do
        institution = FactoryGirl.create(:institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', reported_on_institution: institution)

        # Arrangement that should not be returned
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing')

        Arrangement.search({reported_by: 'others', institution_id: institution.id})[:models].count.should eq(1)
      end

      it 'should return filtered by funder assessments' do
        reported_on_institution = FactoryGirl.create(:institution)

        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: reported_on_institution)

        # Arrangement that should not be returned
        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', reported_on_institution: reported_on_institution)

        Arrangement.search({reported_by: 'others', institution_id: reported_on_institution.id, funder: institution.id})[:models].count.should eq(1)
      end

      it 'should return filtered by recipient assessments' do
        reported_on_institution = FactoryGirl.create(:institution)

        institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming', profile: profile, reported_on_institution: reported_on_institution)

        # Arrangement that should not be returned
        FactoryGirl.create(:arrangement, arrangement_type: 'incoming', reported_on_institution: reported_on_institution)

        Arrangement.search({reported_by: 'others', institution_id: reported_on_institution.id, recipient: institution.id})[:models].count.should eq(1)
      end

      it 'does not return internal/domestic arrangements' do
        institution = FactoryGirl.create(:institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'internal', reported_on_institution: institution)
        FactoryGirl.create(:arrangement, arrangement_type: 'domestic', reported_on_institution: institution)

        Arrangement.search({reported_by: 'others', institution_id: institution.id})[:models].count.should eq(0)
      end
      
      it 'does not return filtered by funder arrangements when trying to filter by recipient' do
        reporting_institution = FactoryGirl.create(:institution)
        profile = FactoryGirl.create(:profile, institution: reporting_institution)

        institution = FactoryGirl.create(:institution)

        FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: institution)

        Arrangement.search({reported_by: 'others', institution_id: institution.id, recipient: reporting_institution.id})[:models].count.should eq(0)
      end
    end
  end
  
  describe '#similar_arrangements' do
    it 'should return similar arrangements' do
      institution = FactoryGirl.create(:institution)
      profile = FactoryGirl.create(:profile, institution: institution)
      reported_on_institution = FactoryGirl.create(:institution)
      arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: reported_on_institution)

      # Similar arrangement
      FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: reported_on_institution)

      arrangement.similar_arrangements.count.should eq(1)
    end

    it 'should not return self' do
      institution = FactoryGirl.create(:institution)
      profile = FactoryGirl.create(:profile, institution: institution)
      reported_on_institution = FactoryGirl.create(:institution)
      arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: reported_on_institution)

      arrangement.similar_arrangements.count.should eq(0)
    end
    
    it 'does not return internal arrangements' do
      institution = FactoryGirl.create(:institution)
      profile = FactoryGirl.create(:profile, institution: institution)
      reported_on_institution = FactoryGirl.create(:institution)
      arrangement = FactoryGirl.create(:arrangement, arrangement_type: 'outgoing', profile: profile, reported_on_institution: reported_on_institution)

      # Almost similar arrangement (but internal)
      FactoryGirl.create(:arrangement, profile: profile, arrangement_type: 'internal', reported_on_institution: institution)

      arrangement.similar_arrangements.count.should eq(0)
    end
  end
end
