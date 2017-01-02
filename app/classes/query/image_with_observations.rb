module Query
  # Images attached to observations.
  class ImageWithObservations < Query::ImageBase
    include Query::Initializers::ObservationFilters

    def parameter_declarations
      super.merge(
        old_by?: :string
      ).merge(observation_filter_parameter_declarations)
    end

    def initialize_flavor
      add_join(:images_observations, :observations)
      initialize_observation_filters
      super
    end

    def default_order
      "name"
    end

    def coerce_into_observation_query
      Query.lookup(:Observation, :all, params_with_old_by_restored)
    end
  end
end
