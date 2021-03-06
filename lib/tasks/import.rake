# encoding: utf-8
namespace :import do

  require 'csv'


  desc "Import Venues"
  task :venues => :environment do
    started_at = Time.now

    puts "Importing Venues starting at #{started_at}"
    data_path = File.expand_path("../../../data/venues.json", __FILE__)
    json = JSON.parse(IO.read(data_path))

    json.each do |venue_json|
      venue_json['name']
      venue = Venue.find_by_name(venue_json['name'])
      if venue.nil?
        venue = Venue.new(:name => venue_json['name'])
      end

      venue.address = venue_json['address']
      venue.postcode = venue_json['postcode']
      venue.latitude = venue_json['lat']
      venue.longitude = venue_json['long']
      venue.save
    end



  end

  desc "Import Aberdeen Sports Village Activities"
  task :asv_sport_activities => :environment do
    started_at = Time.now

    puts "Importing Aberdeen Sports Village activities starting at #{started_at}"
    data_path = File.expand_path("../../../data/ASV_Exercise_classes_140622.csv", __FILE__)
    rows_to_import = CSV.read(data_path, :col_sep => "$", :headers => true)
    total = rows_to_import.count
    puts "#{total} rows to import"

    # Day_of_week$Start_Time$End_Time$Name$Location$Description


    count = 0
    failed = 0

    rows_to_import.each do |row|
      count = count + 1

      activity = 'Exercise Class'
      day_of_week = row[0]
      start_time = row[1]
      end_time = row[2]
      title = row[3]
      room = row[4]
      description = row[5]

      existing_activity = Activity.find_by_title(activity)
      if existing_activity.nil?
        existing_activity = Activity.new(:title => activity, :category => 'sport')
        existing_activity.save
      end

      existing_sub_activity = SubActivity.find_by_title(title)
      if existing_sub_activity.nil?
        existing_sub_activity = SubActivity.new(:title => title, :activity => existing_activity)
        existing_sub_activity.save
      end

      venue = Venue.find_by_name('Aberdeen Sports Village')
      if venue.nil?
        venue = Venue.new(:name => 'Aberdeen Sports Village')
        venue.save
      end

      opportunity = Opportunity.new(:name => "#{title}",
        :category => 'Event',
        :activity => existing_activity,
        :sub_activity => existing_sub_activity,
        :venue => venue,
        :room => room,
        :description => "#{description}",
        :day_of_week => day_of_week,
        :start_time => start_time,
        :end_time => end_time)
      opportunity.save
    end

    completed_at = Time.now
    puts "Import started #{started_at} completed at #{completed_at}"
    puts "#{failed} out of #{total} failed to import"
  end

  desc "Import Aberdeen Aquatics Centre Activities"
  task :aquatics => :environment do

    data_path = File.expand_path("../../../data/aquaticscentreactivities.xml", __FILE__)
    doc = Nokogiri::XML(File.open(data_path))

    root = doc.root
    items = root.xpath("activity")
    items.each do |item|
      activity = Hash.new
      activity['dayofWeek'] = item.at('dayofWeek').text
      activity['startTime'] = item.at('startTime').text
      activity['endTime'] = item.at('endTime').text
      description = item.at('description').text
      description = "Swimming" if description == "Public Swimming"
      subdescription = item.at('subdescription').text
      if subdescription == ""
        subdescription = description
        description = "Swimming"
      end
      activity['description'] = description
      activity['subdescription'] = subdescription
      #activity['poolLength'] = item.at('poolLength').text

      existing_activity = Activity.find_by_title(description)
      if existing_activity.nil?
        existing_activity = Activity.new(:title => description, :category => 'sport')
        existing_activity.save
      end

      existing_sub_activity = SubActivity.find_by_title(subdescription)
      if existing_sub_activity.nil?
        existing_sub_activity = SubActivity.new(:title => subdescription, :activity => existing_activity)
        existing_sub_activity.save
      end

      venue = Venue.find_by_name('Aberdeen Aquatics Centre')
      if venue.nil?
        venue = Venue.new(:name => 'Aberdeen Aquatics Centre')
        venue.save
      end

      opportunity = Opportunity.new(:name => "#{description} - #{subdescription}",
        :category => 'Event',
        :activity => existing_activity,
        :sub_activity => existing_sub_activity,
        :venue => venue,
        :description => "",
        :day_of_week => activity['dayofWeek'],
        :start_time => activity['startTime'],
        :end_time => activity['endTime'])
      opportunity.save


    end
  end


  desc "Import Soft Skills"
  task :skills => :environment do
    started_at = Time.now

    puts "Importing soft skills starting at #{started_at}"
    data_path = File.expand_path("../../../data/softskills.txt", __FILE__)
    rows_to_import = CSV.read(data_path, :col_sep => " ", :headers => false)
    total = rows_to_import.count
    puts "#{total} rows to import"

    count = 0
    failed = 0

    rows_to_import.each do |row|
      count = count + 1

      title = row[0]

      skill = Skill.find_by_title(title)
      if skill.nil?
        skill = Skill.new(:title => title)
        skill.save
      end


      unless skill.valid?
        failed = failed + 1
        puts skill.errors.full_messages
      end
    end

    completed_at = Time.now
    puts "Import started #{started_at} completed at #{completed_at}"
    puts "#{failed} out of #{total} failed to import"
  end


  desc "Import Sport Activities"
  task :sport_activities => :environment do
    started_at = Time.now

    puts "Importing sport activities starting at #{started_at}"
    data_path = File.expand_path("../../../data/sports.txt", __FILE__)
    rows_to_import = CSV.read(data_path, :col_sep => " ", :headers => false)
    total = rows_to_import.count
    puts "#{total} rows to import"

    count = 0
    failed = 0

    rows_to_import.each do |row|
      count = count + 1

      title = row[0]

      activity = Activity.find_by_title(title)
      if activity.nil?
        activity = Activity.new(:title => title, :category => 'sport')
        activity.save
      end


      unless activity.valid?
        failed = failed + 1
        puts activity.errors.full_messages
      end
    end

    completed_at = Time.now
    puts "Import started #{started_at} completed at #{completed_at}"
    puts "#{failed} out of #{total} failed to import"
  end
end