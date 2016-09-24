class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
  				:rememberable, :trackable, :validatable
  validates_length_of :room_number, :on => :create, :is => 4
  has_many :slots
end
