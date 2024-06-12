# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :raise_unless_admin!

  def index; end
end
