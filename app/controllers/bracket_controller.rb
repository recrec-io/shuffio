class BracketController < ApplicationController
  before_action :authenticate_user!, except: [:index, :current]
  def index
  end

  def new
    @bracket = Bracket.new
    @tournament = Tournament.last
  end

  def create
    @tournament = Tournament.last
    @bracket = Bracket.new(
      user: current_user,
      tournament_group: TournamentGroup.find(params[:bracket][:tournament_group_id]),
      match_data: {}
    )

    if @bracket.save
      redirect_to edit_bracket_path(@bracket)
    else
      render 'new'
    end
  end

  def edit
    @bracket = Bracket.find(params[:id])
    @current_round = @bracket.tournament_group.tournament_rounds.first # TODO: programatic
  end

  def show
  end

  def update
    @bracket = Bracket.find(params[:id])
    @current_round = @bracket.tournament_group.tournament_rounds.first # TODO: programatic

    match_selections = @bracket.match_data

    # TODO: ensure all were filled out

    params.each do |p_name, p_value|
      next unless p_name.starts_with?('match_')

      match_id = p_name.split('_').last
      match_selections[match_id] = p_value.to_i
    end

    if @bracket.update(match_data: match_selections)
      # TODO: redirect to next round
      redirect_to current_bracket_path
    else
      render 'edit'
    end
  end

  def current
    @tournament = Tournament.last
    @placeholder_team_ids = ((685..700).to_a + Team.where(name: 'TBD').pluck(:id))
    @chicago_final_match = Tournament.last.tournament_groups[0].tournament_rounds.last.matches[0]
    @brooklyn_final_match = Tournament.last.tournament_groups[1].tournament_rounds.last.matches[0]
    @chi_bkl_final_match = Tournament.last.tournament_groups[2].tournament_rounds.last.matches[0]
  end
end
