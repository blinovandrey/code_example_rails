require 'spec_helper'

RSpec.describe StudyLevel, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"

  context "db" do
    context "indexes" do
      it { should have_db_index(:city_id) }
      it { should have_db_index(:level_id) }
    end

    context "columns" do
    	it { should have_db_column(:level_id).of_type(:integer) }
      it { should have_db_column(:address).of_type(:string) }
      it { should have_db_column(:start_at).of_type(:datetime) }
      it { should have_db_column(:end_at).of_type(:datetime) }
      it { should have_db_column(:cost).of_type(:decimal) }
      it { should have_db_column(:description).of_type(:string) }
      it { should have_db_column(:article).of_type(:string) }
      it { should have_db_column(:city_id).of_type(:integer) }
      it { should have_db_column(:seats).of_type(:integer) }
      it { should have_db_column(:nearest_event).of_type(:boolean) }
      it { should have_db_column(:allow_enroll).of_type(:boolean) }
      it { should have_db_column(:link).of_type(:string) }
    end
  end

  context "attributes" do

    it "has level_id" do
      expect(build(:study_level, level_id: 1)).to have_attributes(level_id: 1)
    end

    it "has address" do
      expect(build(:study_level, address: "test_address")).to have_attributes(address: "test_address")
    end

    it "has start_at" do
    	now = DateTime.now
      expect(build(:study_level, start_at: now)).to have_attributes(start_at: now)
    end

    it "has end_at" do
    	now = DateTime.now
      expect(build(:study_level, end_at: now)).to have_attributes(end_at: now)
    end

    it "has description" do
      expect(build(:study_level, description: "test_decription")).to have_attributes(description: "test_decription")
    end

    it "has article" do
      expect(build(:study_level, article: "test_article")).to have_attributes(article: "test_article")
    end

    it "has city_id" do
      expect(build(:study_level, city_id: 1)).to have_attributes(city_id: 1)
    end

    it "has seats" do
      expect(build(:study_level, seats: 1)).to have_attributes(seats: 1)
    end

    it "has nearest_event" do
      expect(build(:study_level, nearest_event: true)).to have_attributes(nearest_event: true)
    end

    it "has allow_enroll" do
      expect(build(:study_level, allow_enroll: true)).to have_attributes(allow_enroll: true)
    end

    it "has link" do
      expect(build(:study_level, link: "test")).to have_attributes(link: "test")
    end
  end

  context "validation" do

    let(:study_level) { build(:study_level, level_id: 1) }

    it "requires start_at" do
      expect(study_level).to validate_presence_of(:start_at)
    end

    it "requires end_at" do
      expect(study_level).to validate_presence_of(:end_at)
    end

    it "requires address" do
      expect(study_level).to validate_presence_of(:address)
    end

    it "requires cost" do
      expect(study_level).to validate_presence_of(:cost)
    end

    it "requires description" do
      expect(study_level).to validate_presence_of(:description)
    end


    it "requires article" do
      expect(study_level).to validate_presence_of(:article)
    end
  end

  
  context "scopes" do

  	describe ".nearest"

  	it "returns nearest study_level array for level_id" do
  		level_1 = create(:level)
  		level_2 = create(:level)

  		StudyLevel.skip_callback(:commit, :after, :add_to_sidekiq)
  		StudyLevel.skip_callback(:commit, :after, :start_notification_worker)

      study_level_1 = create(:study_level, level: level_1, start_at: DateTime.now + 3.days)
      study_level_2 = create(:study_level, level: level_1, start_at: DateTime.now + 2.days)
      study_level_3 = create(:study_level, level: level_1, start_at: DateTime.now + 1.days)
      study_level_4 = create(:study_level, level: level_2, start_at: DateTime.now + 3.days)

      expect(StudyLevel.nearest(level_1.id)).to match_array [study_level_3, study_level_2, study_level_1]
    end
  end
end
