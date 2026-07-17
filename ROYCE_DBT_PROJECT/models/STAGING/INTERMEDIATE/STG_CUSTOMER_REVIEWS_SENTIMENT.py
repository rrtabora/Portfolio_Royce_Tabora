import re

import snowflake.snowpark.functions as F
from snowflake.snowpark.types import (
    StringType,
    StructField,
    StructType
)


def model(dbt, session):

    dbt.config(
        materialized="table",
        python_version="3.11",
        packages=[
            "snowflake-snowpark-python",
            "textblob",
            "scikit-learn"
        ]
    )

    reviews = session.table(
        "PORTFOLIO_DB.STAGING.STG_CUSTOMER_REVIEWS"
    )

    output_schema = StructType([
        StructField("SENTIMENT", StringType()),
        StructField("MOOD", StringType()),
        StructField("KEY_WORD_BEST", StringType()),
        StructField("KEY_WORD_WORST", StringType())
    ])

    def analyse_review(review_text):

        from textblob import TextBlob
        from sklearn.feature_extraction.text import ENGLISH_STOP_WORDS

        if review_text is None or not str(review_text).strip():
            return {
                "SENTIMENT": "NEUTRAL",
                "MOOD": "INDIFFERENT",
                "KEY_WORD_BEST": "NONE",
                "KEY_WORD_WORST": "NONE"
            }

        text = str(review_text).strip()

        overall_polarity = TextBlob(
            text
        ).sentiment.polarity

        # Split the review into sentences without requiring
        # additional TextBlob or NLTK tokenizer files.
        sentences = [
            sentence.strip()
            for sentence in re.split(
                r"[.!?]+",
                text
            )
            if sentence.strip()
        ]

        sentence_polarities = [
            TextBlob(
                sentence
            ).sentiment.polarity
            for sentence in sentences
        ]

        has_positive = any(
            polarity >= 0.15
            for polarity in sentence_polarities
        )

        has_negative = any(
            polarity <= -0.15
            for polarity in sentence_polarities
        )

        # Assign sentiment and mood.
        if has_positive and has_negative:
            sentiment = "MIXED"

            if overall_polarity > 0.15:
                mood = "CAUTIOUSLY SATISFIED"

            elif overall_polarity < -0.15:
                mood = "DISAPPOINTED"

            else:
                mood = "UNCERTAIN"

        elif overall_polarity >= 0.20:
            sentiment = "POSITIVE"

            if overall_polarity >= 0.60:
                mood = "DELIGHTED"

            elif overall_polarity >= 0.40:
                mood = "IMPRESSED"

            else:
                mood = "SATISFIED"

        elif overall_polarity <= -0.20:
            sentiment = "NEGATIVE"

            if overall_polarity <= -0.60:
                mood = "FRUSTRATED"

            elif overall_polarity <= -0.40:
                mood = "DISAPPOINTED"

            else:
                mood = "DISSATISFIED"

        else:
            sentiment = "NEUTRAL"
            mood = "INDIFFERENT"

        # Clean the review text before generating keywords.
        clean_text = re.sub(
            r"[^a-zA-Z0-9\s'-]",
            " ",
            text.lower()
        )

        words = [
            word
            for word in clean_text.split()
            if (
                len(word) > 2
                and word not in ENGLISH_STOP_WORDS
                and not word.isdigit()
            )
        ]

        candidates = []

        # Single-word keyword candidates.
        candidates.extend(
            words
        )

        # Two-word phrase candidates.
        candidates.extend([
            (
                f"{words[index]} "
                f"{words[index + 1]}"
            )
            for index in range(
                len(words) - 1
            )
        ])

        # Three-word phrase candidates.
        candidates.extend([
            (
                f"{words[index]} "
                f"{words[index + 1]} "
                f"{words[index + 2]}"
            )
            for index in range(
                len(words) - 2
            )
        ])

        scored_candidates = []

        # Score each candidate dynamically using TextBlob.
        for candidate in set(candidates):

            candidate_sentiment = TextBlob(
                candidate
            ).sentiment

            polarity = (
                candidate_sentiment.polarity
            )

            subjectivity = (
                candidate_sentiment.subjectivity
            )

            if polarity != 0:
                scored_candidates.append(
                    (
                        candidate,
                        polarity,
                        subjectivity,
                        len(candidate.split())
                    )
                )

        positive_candidates = [
            candidate
            for candidate in scored_candidates
            if candidate[1] > 0
        ]

        negative_candidates = [
            candidate
            for candidate in scored_candidates
            if candidate[1] < 0
        ]

        # Put the strongest positive phrase first.
        # Prefer longer phrases when scores are tied.
        positive_candidates.sort(
            key=lambda value: (
                value[1],
                value[2],
                value[3]
            ),
            reverse=True
        )

        # Put the strongest negative phrase first.
        # Prefer longer phrases when scores are tied.
        negative_candidates.sort(
            key=lambda value: (
                value[1],
                -value[2],
                -value[3]
            )
        )

        key_word_best = (
            positive_candidates[0][0].upper()
            if positive_candidates
            else "NONE"
        )

        key_word_worst = (
            negative_candidates[0][0].upper()
            if negative_candidates
            else "NONE"
        )

        # StructType output must be returned as a dictionary.
        return {
            "SENTIMENT": sentiment,
            "MOOD": mood,
            "KEY_WORD_BEST": key_word_best,
            "KEY_WORD_WORST": key_word_worst
        }

    analyse_review_udf = session.udf.register(
        func=analyse_review,
        return_type=output_schema,
        input_types=[
            StringType()
        ],
        packages=[
            "textblob",
            "scikit-learn"
        ],
        is_permanent=False
    )

    result = (
        reviews
        .with_column(
            "_ANALYSIS",
            analyse_review_udf(
                F.col("REVIEW_TEXT")
            )
        )
        .with_column(
            "SENTIMENT",
            F.col(
                "_ANALYSIS"
            )["SENTIMENT"].cast(
                "STRING"
            )
        )
        .with_column(
            "MOOD",
            F.col(
                "_ANALYSIS"
            )["MOOD"].cast(
                "STRING"
            )
        )
        .with_column(
            "KEY_WORD_BEST",
            F.col(
                "_ANALYSIS"
            )["KEY_WORD_BEST"].cast(
                "STRING"
            )
        )
        .with_column(
            "KEY_WORD_WORST",
            F.col(
                "_ANALYSIS"
            )["KEY_WORD_WORST"].cast(
                "STRING"
            )
        )
        .drop(
            "_ANALYSIS"
        )
    )

    return result
