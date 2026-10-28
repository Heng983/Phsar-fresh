export default function Loading() {
  return (
    <main className="pf-shell-content" aria-busy="true">
      <div className="pf-skel" style={{ height: 64 }} />
      <div className="pf-grid pf-grid-4">{[0, 1, 2, 3].map((i) => <div key={i} className="pf-skel" style={{ height: 140 }} />)}</div>
      <div className="pf-skel" style={{ height: 320 }} />
    </main>
  );
}
