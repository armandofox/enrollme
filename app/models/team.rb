class Team < ActiveRecord::Base
    has_many :users
    has_many :requests
    has_one :submission

    #validates_inclusion_of :waitlisted, :in => [true, false]
    #validates :waitlisted, inclusion: { in: [ true, false ] }
    attr_accessor :num_pending_requests, :declared, :request

    validate :size_cannot_be_too_big

    def size_cannot_be_too_big
        if self.getNumMembers > 6
            errors.add(:size, "The team is already full")
        end
    end

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
            EmailStudents.submit_email(user).deliver_later
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

    def getMembers # returns the names of all members in the group, to be displayed in proper format in the team listings table
        self.users.map {|user| user.name}.join(', ')
    end

    def getMembersNamesArray
         names = []
         self.users.each{|user| names.push(user.name)}
         return names
    end

    def getMembersTimeCommitmentArray
        times = []
        self.users.each{|user| times.push(user.time_commitment)}
        return times
    end

    def getMembersBioArray
         bios = []
         self.users.each{|user| bios.push(user.bio)}
         return bios
    end

    def getMembersFacebookArray
         fbs = []
         self.users.each{|user| fbs.push(user.facebook)}
         return fbs
    end

    def getMembersLinkedinArray
         lks = []
         self.users.each{|user| lks.push(user.linkedin)}
         return lks
    end

    def getMembersExperiencesArray
         exps = []
         self.users.each{|user| exps.push(user.experience)}
         return exps
    end

    def getMembersEmailsArray
         emails = []
         self.users.each{|user| emails.push(user.email)}
         return emails
    end

    def getMembersPicsArray
        pics = []
        self.users.each{|user| pics.push(user.avatar.url(:medium))}
        return pics
    end

    def getNumMembers # returns the number of members in this group
        self.users.count
    end

    def pending_requests
        @pending_requests = 0
    end

    def self.all_declared
        %w(Yes No)
    end

    def declared
        return self.users.all?{|user| user.major == 'DECLARED CS/EECS Major'}
    end

    def isFull?
        return self.getNumMembers >= 6
    end

    def update_waitlist
      @waitlisted = true
      self.users.each do |u|
        if  u.waitlisted == false
          @waitlisted = false
        end
      end
      self.waitlisted = @waitlisted
      self.save!
    end

end
