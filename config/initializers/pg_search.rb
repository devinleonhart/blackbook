# see https://github.com/Casecommons/pg_search for a description of this gem
PgSearch.multisearch_options = {
  using: {
    tsearch: {
      prefix: true,
      dictionary: "english",

      # for description of all highlighting options see
      # https://www.postgresql.org/docs/current/textsearch-controls.html#TEXTSEARCH-HEADLINE
      highlight: {
        StartSel: '<strong>',
        StopSel: '</strong>',
        ShortWord: 3,
        HighlightAll: false,
        MaxFragments: 3,
      },
    },
  },
}
