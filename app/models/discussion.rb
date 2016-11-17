class Discussion < ActiveRecord::Base
    has_many :teams
    
    def can_take_team?(team)
        return !!(team.users.length + count_students <= self.capacity)
    end
    
    def is_full?
       return !!(count_students >= capacity)
    end
    
    def seats_open
        return self.capacity - count_students
    end
    
    def count_students
        num_students = 0
        self.teams.each do |team|
            num_students += team.users.length
        end
        return num_students
    end
    
    
    def self.valid_discs_for(team)
        discs = []
        Discussion.all.each do |disc|
            discs << disc if (disc.can_take_team?(team))
        end
        return discs
    end

end