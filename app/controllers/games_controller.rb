require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = (0...10).map { ('A'..'Z').to_a[rand(26)] }#.join
  end

  def score
    # raise
    @letters = params[:token].split('')
    @word = params[:word]

    grid = @letters
    attempt = @word.gsub(/\s+/, '').downcase
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    user_serialized = open(url).read
    user = JSON.parse(user_serialized)

    result = {}
    score = attempt.size

    attempt_hash = {}
    attempt.upcase.split('').each { |letter| attempt_hash[letter] = attempt.upcase.split('').count(letter) }
    grid_hash = {}
    grid.each { |letter| grid_hash[letter] = grid.count(letter) }
    validate = []
    attempt_hash.each do |key, value|
      if grid_hash.key?(key) == false
        validate << false
      elsif grid_hash[key] >= value
        validate << true
      else
        validate << false
      end
    end

    unless user["found"] != true && validate.include?(false)
      result[:score] = score
      result[:message] = "Well Done"
    end

    if user["found"] == true && validate.include?(false)
      result[:score] = 0
      result[:message] = "#{attempt} is not in the grid"
    end

    if user["found"] == false
      result[:score] = 0
      result[:message] = "#{attempt} is not an english word"
    end
    @score = result[:score]
    @message = result[:message]
  end
end
