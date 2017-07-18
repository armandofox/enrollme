class Team < ActiveRecord::Base
    has_many :users
    has_one :submission
    validates :passcode, uniqueness: true
    attr_accessor :members, :num_members, :pending_requests, :declared
  

    def self.generate_hash(length=36)
        return SecureRandom.urlsafe_base64(length, false)
    end
    
    def self.approved_teams
        return Team.where(:approved => true)
    end
    
    def withdraw_submission
        self.submitted = false
        self.save!
    end

    def disapprove
        self.approved = false
        self.submitted = false
        self.save!
    end

    def withdraw_approval
        self.approved = false
        self.save!
    end
    
    def approve_with_discussion(id)
        self.approved = true
        self.discussion_id = id
        self.save!
    end
    
    def send_submission_reminder_email
        self.users.each do |user|
            #EmailStudents.submit_email(user).deliver_later
        end
    end
    
    def eligible?
        users.count.between?(Option.minimum_team_size, Option.maximum_team_size)
    end
    
    
    def self.filter_by(status)
        if status.nil? or status == "Pending | Approved"
            return Team.where(approved: true) + Team.where(approved: false, submitted: true)
        elsif status == "Approved"
            return Team.where(approved: true)
        elsif status == "Pending"
            return Team.where(approved: false, submitted: true)
        elsif status == "Forming"
            return Team.where(approved: false, submitted: false)
        end
        return Team.all.each
    end
    
    def add_submission(id)
        self.update(submitted: true)
        self.submission_id = id
        self.save!
    end
    
    def can_join?
      ! passcode.nil?  &&
        ! approved     &&
        users.size < Option.maximum_team_size
    end
    
    # Summer '17 Code
    
    def set_members # returns the names of all members in the group, to be displayed in proper format in the team listings table
        names = ''
        self.users.each do |u|
           if names == ''
               names = u.name # not sure if this is proper way to call user name
           else
               names = names + ', ' + u.name
           end
       end
       self.members = names
    end
    
    def set_num_members # simple getter method for checking number of users in team
        self.num_members = self.users.size
    end

    def set_pending_requests(req)
        if req == 'join'
            self.pending_requests += 1
        elsif req == 'leave'
            self.pending_requests -= 1
        end
    end

    def self.all_declared
        %w(Yes No)
    end
    
    def set_declared
        result = true
        self.users.each do |user|
            if user.major != 'DECLARED CS/EECS Major'
                result = false
            end
        end
        if result == true
            self.declared = 'Yes'
        else
            self.declared = 'No'
        end
        self.save!
    end
    
    # def self.check_declared
    #     if self.declared == true
    #         return 'Yes'
    #     else
    #         return 'No'
    #     end
    # end
    
    # TODO def self.join # implement to return join/leave/invite properly depending on session user's relation to team
    #    return 'Join'
    # end
end
