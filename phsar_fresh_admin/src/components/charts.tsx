/** Static (server-rendered) charts. */

export function BarChart({ data, height = 200, label }: { data: { label: string; value: number }[]; height?: number; label: string }) {
  const W = 640, H = height, L = 32, R = 8, T = 18, B = 26;
  const peak = Math.max(0, ...data.map((d) => d.value));
  const max = peak <= 4 ? 4 : Math.ceil(peak / 4) * 4;
  const iw = W - L - R, ih = H - T - B;
  const bw = iw / data.length, gap = Math.min(10, bw * 0.3);
  const top = data.findIndex((d) => d.value === peak && peak > 0);
  return (
    <svg className="pf-chart" viewBox={`0 0 ${W} ${H}`} role="img" aria-label={label}>
      {[0, 0.5, 1].map((t, i) => {
        const yy = T + ih - t * ih;
        return (
          <g key={i}>
            <line className="pf-chart-grid" x1={L} x2={W - R} y1={yy} y2={yy} />
            <text className="pf-chart-axis" x={L - 6} y={yy + 4} textAnchor="end">{Math.round(t * max)}</text>
          </g>
        );
      })}
      {data.map((d, i) => {
        const bh = (d.value / max) * ih, bx = L + i * bw + gap / 2, w = bw - gap;
        return (
          <g key={i}>
            <rect className={`pf-chart-bar${i !== top ? " is-muted" : ""}`} x={bx} y={T + ih - bh} width={w} height={Math.max(bh, d.value ? 2 : 0)} rx={Math.min(4, w / 2)}>
              <title>{`${d.label}: ${d.value}`}</title>
            </rect>
            {i === top && <text className="pf-chart-value" x={bx + w / 2} y={T + ih - bh - 6} textAnchor="middle">{d.value}</text>}
            {i % 3 === 0 && <text className="pf-chart-axis" x={bx + w / 2} y={H - 8} textAnchor="middle">{d.label}</text>}
          </g>
        );
      })}
    </svg>
  );
}

export function RankList({ items }: { items: { name: string; nameKm?: string | null; value: number; display?: string }[] }) {
  const max = Math.max(1, ...items.map((i) => i.value));
  return (
    <ol className="pf-rank">
      {items.map((it, i) => (
        <li key={it.name + i}>
          <span className="pf-rank-n">{i + 1}</span>
          <span className="pf-rank-name">{it.name}{it.nameKm && <small>{it.nameKm}</small>}</span>
          <span className="pf-rank-val">{it.display ?? it.value}</span>
          <span className="pf-bar"><span style={{ width: `${(it.value / max) * 100}%` }} /></span>
        </li>
      ))}
    </ol>
  );
}
