class Bill < ActiveRecord::Base
  belongs_to :state
  belongs_to :session
  belongs_to :chamber

  has_many :sponsorships, :dependent => :destroy
  has_many :sponsors, :through  => :sponsorships

  has_many :versions, :dependent => :destroy
  has_many :actions, :dependent => :destroy
  has_many :votes, :dependent => :destroy

  named_scope :titles_like, lambda { |t| { :conditions => ["lower(bill_number) = ? or title like ?", "#{t.downcase}", "%#{t}%"] } }
  named_scope :in_chamber, lambda { |c| { :conditions => ["chamber_id = ?", c] } } 
  named_scope :for_session, lambda { |s| { :conditions => ["sessions.name = ?", s], :joins => [:session] } }

  class << self
    def find_by_session_name_and_param(session, param)
      for_session(session).find_by_bill_number(param.titleize.upcase)
    end

    def search(params)
      scope = Bill.scoped({})
      scope = scope.titles_like(params[:titles_like]) if params[:titles_like]
      scope = scope.in_chamber(params[:chamber_id]) if params[:chamber_id]
    end
  end

  def to_param
    bill_number.parameterize
  end
end
