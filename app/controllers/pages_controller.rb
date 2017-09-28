require 'open-uri'
require 'json'

class PagesController < ApplicationController
  def score
    @player_answer = params[:player_answer]
    @time = Time.now() - Time.parse(params[:start_time])
    @grid = params[:grid].delete(' ')
    @score_and_message = score_and_message(@player_answer, @grid, @time)
  end

  def game
    @grid_size = params[:grid_size].to_i
    @grid = Array.new(@grid_size) { ('A'..'Z').to_a.sample }.join(" ")
    @start_time = Time.now()
  end

  def grid
  end

  private

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    return json['found']
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        score = score.round(2)
        [score, "WELL DONE"]
      else
        [0, "Erorr: your word is not an english word"]
      end
    else
      [0, "Erorr: your word is not in the grid"]
    end
  end

end
