class SelectionSetsController < ApplicationController
    def index
    end

    def new
      @selection_set = SelectionSet.new
    end

    def create
      SelectionSet.destroy_all
      byebug
        #should nuke and pave, delete old selection record as we should have only one at a time
    end

    private


    def selection_set_params
      obj = OpenStruct.new(params.require(:selection_set))

      
    end
end
