from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Tuple, Literal

import matplotlib.pyplot as plt
import pandas as pd
from pandas.api.types import CategoricalDtype


@dataclass
class PlotConfig:

    order: List[str] = field(
        default_factory=lambda: [
            "Fatality",
            "Hospitalized injury",
            "Minor injury",
            "Unharmed",
            "Unknown",
        ]
    )

    colours: Dict[str, str] = field(
        default_factory=lambda: {
            "Fatality": "#D52000",
            "Hospitalized injury": "#E69F00",
            "Minor injury": "#56B4E9",
            "Unharmed": "#009E73",
            "Unknown": "#7F7F7F",
        }
    )
    plots_dir: Path = Path("plots")

    def __post_init__(self) -> None:
        self.plots_dir.mkdir(exist_ok=True, parents=True)


class SeverityEDA:

    _essential_cols = [
        "severity_label",
        "geographic_scope",
        "age_group_label",
        "day_of_week_label",
        "hour",
    ]

    def __init__(self, *, config: PlotConfig | None = None) -> None:
        self.cfg = config or PlotConfig()
        self.df: pd.DataFrame | None = None

    def set_data(self, df: pd.DataFrame) -> None:
        self.df = df.copy()
        if "severity_label" not in self.df:
            raise ValueError("Column 'severity_label' is required but not found.")
        cat = CategoricalDtype(categories=self.cfg.order, ordered=True)
        self.df["severity_label"] = self.df["severity_label"].astype(cat)

    def summary(self) -> None:

        if self.df is None:
            raise RuntimeError("No data – run set_data() first.")
        counts = self.df["severity_label"].value_counts().reindex(self.cfg.order)
        pct = counts / counts.sum() * 100

        print("\n=== Severity overview ===")
        for sev in counts.index:
            n = counts[sev]
            if pd.isna(n):
                continue
            print(f"{sev:20} | {n:7,.0f} cases | {pct[sev]:5.1f}%")
        print("Total accidents:", int(counts.sum()))

    def analyze(self, column: str, *, kind: Literal["bar", "barh"] = "bar") -> Tuple[pd.DataFrame, pd.DataFrame]:

        if self.df is None:
            raise RuntimeError("No data – run set_data() first.")
        if column not in self.df:
            raise ValueError(f"Column '{column}' not in DataFrame.")

        # Crosstab counts & percentages
        counts = pd.crosstab(self.df[column], self.df["severity_label"])
        pct = counts.div(counts.sum(axis=1), axis=0) * 100

        pct_sorted = self._sort_data_for_plotting(pct)

        print(f"\n=== Severity by {column} ===")
        for idx in pct_sorted.index:
            row = pct_sorted.loc[idx]
            total = counts.loc[idx].sum()
            print(f"\n{idx} (n={total:,})")
            for sev in self.cfg.order:
                if sev in pct_sorted.columns:
                    print(f"  {sev:20} | {row[sev]:5.1f}% ({counts.loc[idx, sev]:,})")

        self._plot(pct_sorted, title=f"Severity vs {column}", kind=kind, fname=f"severity_{column}.png")
        return pct_sorted, counts

    def _sort_data_for_plotting(self, data: pd.DataFrame) -> pd.DataFrame:

        unknown_keywords = ['unknown', 'not specified', 'unspecified', 'invalid', 'none']
        idx = data.index.astype(str).str.lower()
        is_unknown = idx.str.contains('|'.join(unknown_keywords), na=False)

        known = data.loc[~is_unknown].copy()
        if {"Fatality", "Hospitalized injury"}.issubset(known.columns):
            known["_priority"] = known["Fatality"] + known["Hospitalized injury"]
            known = known.sort_values("_priority", ascending=False).drop(columns="_priority")

        unknown = data.loc[is_unknown].copy()
        if {"Fatality", "Hospitalized injury"}.issubset(unknown.columns):
            unknown["_priority"] = unknown["Fatality"] + unknown["Hospitalized injury"]
            unknown = unknown.sort_values("_priority", ascending=False).drop(columns="_priority")

        return pd.concat([known, unknown])

    def _plot(self, data: pd.DataFrame, *, title: str, kind: Literal["bar", "barh"], fname: str) -> None:

        cols = [c for c in self.cfg.order if c in data.columns]
        data = data[cols]

        colours = [self.cfg.colours[c] for c in data.columns]
        ax = data.plot(kind=kind, stacked=True, figsize=(10, 5), color=colours)
        ax.set_title(title)
        ax.set_ylabel("Percentage (%)")
        ax.legend(title="Severity", bbox_to_anchor=(1.02, 1), loc="upper left")
        ax.tick_params(axis="x", rotation=45)

        # Only add labels for bar charts, not other plot types
        if kind == "bar":
            from matplotlib.container import BarContainer
            for container in ax.containers:
                if isinstance(container, BarContainer):
                    datavalues = getattr(container, 'datavalues', [])
                    if hasattr(datavalues, '__iter__'):
                        labels = [
                            f"{val:.1f}%" if val >= 0.5 else ""
                            for val in datavalues
                        ]
                    else:
                        labels = []

                    ax.bar_label(
                        container,
                        fmt="%.1f%%",
                        labels=labels,
                        label_type="center",  
                        color="white",
                        fontsize=6,
                        fontweight="bold"
                    )

        plt.tight_layout()

        plt.savefig(self.cfg.plots_dir / fname, dpi=300)
        plt.show()