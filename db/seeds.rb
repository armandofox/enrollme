# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
people = [
  		{ :name => "John"                   ,:major => "English"  , :sid => "111"  ,:email => "111@berkeley.edu",:password => "132619"        },
  		{ :name =>  "Josh"                   ,:major => "CS"  ,:sid => "222"  ,:email => "222@berkeley.edu", :password => "666666"         },
  		{ :name =>  "Jorge"                   ,:major => "English"  ,:sid => "333"  ,:email => "333@berkeley.edu",:password => "057663"         },
  		{ :name =>  "CCC"                   ,:major => "EECS"  ,:sid => "444"  ,:email => "444@berkeley.edu",:password => "012343"         },
 	  	{ :name =>  "DDD"                   ,:major => "English"  ,:sid => "555"  ,:email => "555@berkeley.edu",:password =>"144083"         },
 	  	{:name =>  "EEE"                   , :major =>"English"  ,:sid => "666"  ,:email => "666@berkeley.edu" ,:password =>  "920114"        },
 	  	{:name => "FFF"                   ,:major => "EECS"  ,:sid => "777" ,:email => "777@berkeley.edu",:password => "783986"         },
 	  	{:name => "GGG"                   ,:major => "CS"  ,:sid => "888" ,:email => "888@berkeley.edu",:password => "564742"         },
 	  	{:name =>  "HHH"                   ,:major => "English"  ,:sid => "999" ,:email =>"999@berkeley.edu" ,:password => "634846"        },
 	  	{:name =>  "III"                   ,:major => "English"  ,:sid => "1111" ,:email => "1111@berkeley.edu"     ,:password => "663607"    },
 	  	{:name =>  "JJJ"                   ,:major => "English"  ,:sid => "2222" ,:email => "2222@berkeley.edu",:password => "464123"         },
 	  	{:name =>  "Kay"                   ,:major => "EECS"  ,:sid => "3333" ,:email => "3333@berkeley.edu",:password => "370603"         },
 	  	{:name =>  "Ana"                   ,:major => "CS"  ,:sid => "4444" ,:email => "4444@berkeley.edu" ,:password =>"758603"        }
    ]
    
people.each do |ue|
  User.create!( ue)
end



tone = Team.new
tone.approved = true
tone.passcode = "passcode1"
tone.save!
tone.users << User.where(name: "Josh")
tone.users << User.where(name: "CCC")
tone.users << User.where(name: "GGG")


two = Team.new
two.approved = false
two.passcode = "passcode2"
two.save!
two.users << User.where(name: "JJJ")
two.users << User.where(name: "DDD")
two.users << User.where(name: "John")


#Client.find_by! first_name: 'does not exist'
"""
  ue = User.new
  ue.name = names
  ue.major = majors
  ue.sid = sids
  ue.email = emails
  ue.password = passwords
  ue.save!
"""


admins = [
  		{ :name => "Anna", :email => "aaa@berkeley.edu",:password => "appleaimer" },
  		{ :name => "Bruce", :email => "bbb@berkeley.edu",:password => "bananabruiser" },
  ]
  
admins.each do |a|
  Admin.create!(a)
end