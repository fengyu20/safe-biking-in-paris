{% macro _clean_numeric_base(expr) %}
  -- 1. remove NBSP (U+00A0), 2. trim, 3. convert comma to dot
  REPLACE(
    REPLACE(TRIM({{ expr }}), ' ', ''),  
    ',', '.'
  )
{% endmacro %}

{% macro cast_int(expr, allow_codes=false) %}
SAFE_CAST(
  CASE
    WHEN {{ expr }} IS NULL THEN NULL
    WHEN TRIM({{ expr }}) = ''        THEN NULL         -- true missing
    {%- if not allow_codes %}
    WHEN TRIM({{ expr }}) IN ('0','-1','-1.0') THEN NULL  -- ignore sentinels
    {%- endif %}
    ELSE {{ _clean_numeric_base(expr) }}
  END AS INT64
)
{% endmacro %}

{% macro cast_float(expr, allow_codes=false) %}
SAFE_CAST(
  CASE
    WHEN {{ expr }} IS NULL THEN NULL
    WHEN TRIM({{ expr }}) = ''        THEN NULL
    {%- if not allow_codes %}
    WHEN TRIM({{ expr }}) IN ('-1','-1.0') THEN NULL
    {%- endif %}
    ELSE {{ _clean_numeric_base(expr) }}
  END AS FLOAT64
)
{% endmacro %}