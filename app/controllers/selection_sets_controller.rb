class SelectionSetsController < ApplicationController
    def index
    end

    def new
      @selection_set = SelectionSet.new
    end

    def create
      SelectionSet.destroy_all
      @selection_set = SelectionSet.new(selection_set_params)

      if @selection_set.save
        redirect_to selection_set_path(id: @selection_set.reload.id), notice: 'SelectionSet was successfully created.'
      else
        render :new
      end
        #should nuke and pave, delete old selection record as we should have only one at a time
    end

    def show
      @selection_set = SelectionSet.find(params[:id])
    end

    private


    def selection_set_params
      params
        .require(:selection_set)
        .permit(
          :selection_set_type,
          :start_date,
          :end_date,
          :ignore_dates_use_nulls,
          :use_size_breaks,
          :use_gloves_in_size_breaks,
          :leggings,
          :tops,
          :sports_bra,
          :sports_jacket,
          :gloves
          )
    end
end
