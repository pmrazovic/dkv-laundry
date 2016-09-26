class SlotsController < ApplicationController
  before_action :set_slot, only: [:show, :edit, :update, :destroy]

  # GET /slots
  # GET /slots.json
  def index
    if params["week"].nil?
      @week = 0
    else
      @week = params["week"].to_i
    end

    if @week >= 0 && @week <= 4
      target_date = Date.today + @week.weeks
    end

    beginning_of_week = target_date.at_beginning_of_week
    end_of_week = target_date.at_end_of_week
    days_from_this_week = (beginning_of_week..end_of_week).map

    @time_slots = ActiveSupport::OrderedHash.new
    days_from_this_week.each do |current_date|
      @time_slots[current_date] = [ { :start => Time.new(current_date.year, current_date.month, current_date.day, 0, 0, 0),
                                      :finish => Time.new(current_date.year, current_date.month, current_date.day, 2, 0, 0) },
                                    { :start => Time.new(current_date.year, current_date.month, current_date.day, 2, 0, 0),
                                      :finish => Time.new(current_date.year, current_date.month, current_date.day, 4, 0, 0) },
                                    { :start => Time.new(current_date.year, current_date.month, current_date.day, 4, 0, 0),
                                      :finish => Time.new(current_date.year, current_date.month, current_date.day, 6, 0, 0) },
                                    { :start => Time.new(current_date.year, current_date.month, current_date.day, 6, 0, 0),
                                      :finish => Time.new(current_date.year, current_date.month, current_date.day, 8, 0, 0) },
                                    { :start => Time.new(current_date.year, current_date.month, current_date.day, 8, 0, 0),
                                      :finish => Time.new(current_date.year, current_date.month, current_date.day, 10, 0, 0) },
                                    { :start => Time.new(current_date.year, current_date.month, current_date.day, 10, 0, 0),
                                      :finish => Time.new(current_date.year, current_date.month, current_date.day, 12, 0, 0) },
                                    { :start => Time.new(current_date.year, current_date.month, current_date.day, 12, 0, 0),
                                      :finish => Time.new(current_date.year, current_date.month, current_date.day, 14, 0, 0) },
                                    { :start => Time.new(current_date.year, current_date.month, current_date.day, 14, 0, 0),
                                      :finish => Time.new(current_date.year, current_date.month, current_date.day, 16, 0, 0) },
                                    { :start => Time.new(current_date.year, current_date.month, current_date.day, 16, 0, 0),
                                      :finish => Time.new(current_date.year, current_date.month, current_date.day, 18, 0, 0) },
                                    { :start => Time.new(current_date.year, current_date.month, current_date.day, 18, 0, 0),
                                      :finish => Time.new(current_date.year, current_date.month, current_date.day, 20, 0, 0) },
                                    { :start => Time.new(current_date.year, current_date.month, current_date.day, 20, 0, 0),
                                      :finish => Time.new(current_date.year, current_date.month, current_date.day, 22, 0, 0) },
                                    { :start => Time.new(current_date.year, current_date.month, current_date.day, 22, 0, 0),
                                      :finish => Time.new(current_date.year, current_date.month, current_date.day+1, 0, 0, 0) },
                                  ]
    end  

    slots = Slot.where("start >= ? AND start <= ?", 
                        Time.new(beginning_of_week.year, beginning_of_week.month, beginning_of_week.day, 0, 0, 0),
                        Time.new(end_of_week.year, end_of_week.month, end_of_week.day, 23, 59, 59))
    
    @booked_slots = Hash.new
    slots.each do |slot|
      @booked_slots[slot.start] = slot
    end
  end

  # POST /slots
  # POST /slots.json
  def create
    errors = []
    if current_user.slots.length > 0
      errors << "You cannot book more than one slot at the time!"
    elsif Slot.where(:room_number => current_user.room_number).length > 0
      errors << "There already exists a slot booked for your room number!"
    elsif Slot.where(:start => params["start"].to_time, :finish => params["finish"].to_time).length > 0
      errors << "Another user already booked this slot!"
    elsif params["finish"].to_time < Time.now
      errors << "You cannot book expired slots!"
    end

    if errors.blank?
      @slot = Slot.create(:user_id => current_user.id, :room_number => current_user.room_number, :start => params["start"].to_time, :finish => params["finish"].to_time)
      redirect_to :back
    else
      flash[:error] = errors.join(" ")
      redirect_to :back
    end
  end

  # DELETE /slots/1
  # DELETE /slots/1.json
  def destroy
    errors = []
    if @slot.nil?
      errors << "Slot has been already released!"
    elsif @slot.user != current_user
      errors << "You cannot release another user's slot!"
    end

    if errors.blank?
      @slot.destroy
      redirect_to :back
    else
      flash[:error] = errors.join(" ")
      redirect_to :back
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_slot
      @slot = Slot.where(:id => params[:id]).first
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def slot_params
      params.fetch(:slot, {})
    end
end
