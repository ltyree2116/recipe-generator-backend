# app/controllers/api/v1/recipes_controller.rb
module Api
  module V1
    class RecipesController < ApplicationController
      def index
        render json: Recipe.all
      end

      def show
        render json: Recipe.find(params[:id])
      end

      def create
        user_preferences = params[:user_preferences]

        if user_preferences.blank?
          render json: { error: 'User preferences required' }, status: :unprocessable_entity
          return
        end

        generated = generate_recipe_from_ai(user_preferences)

        recipe = Recipe.new(
          title: generated[:title],
          ingredients: generated[:ingredients],
          instructions: generated[:instructions],
          tags: generated[:tags],
          user_preferences: user_preferences,
          ai_generated: true
        )

        if recipe.save
          render json: recipe, status: :created
        else
          render json: recipe.errors, status: :unprocessable_entity
        end
      end

      private

      def generate_recipe_from_ai(user_preferences)
        prompt = <<~PROMPT
          Create a recipe based on these preferences: #{user_preferences}.
          The recipe should be suitable for a home cook.
          Assume the user has basic cooking skills and access to common kitchen equipment.
          Assume the user only has kitchen staples like salt, pepper, oil, and flour.
          Include title, ingredients, instructions, and tags. Return as JSON.
        PROMPT

        content = OpenaiChatService.new.chat(prompt)
        # Remove Markdown code block if present
        json_str = content.gsub(/\A```json\s*|\s*```\s*\z/, "")
        JSON.parse(json_str).symbolize_keys
      rescue
        {
          title: "Untitled Recipe",
          ingredients: "Unable to fetch ingredients.",
          instructions: "No instructions available.",
          tags: "AI"
        }
      end

      def openai_client
        @openai_client ||= OpenAI::Client.new(api_key: ENV.fetch("OPENAI_API_KEY"))
      end
    end
  end
end