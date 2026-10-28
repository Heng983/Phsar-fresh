"use client";

import { useRef, useState } from "react";
import { useFormStatus } from "react-dom";
import { Icon } from "@/components/icon";
import { useDict } from "@/i18n/client";

function Tile({ src, label, busy }: { src: string | null; label: string; busy?: boolean }) {
  const t = useDict().categories;
  return (
    <span className={`pf-cat-photo${busy ? " is-busy" : ""}`}>
      {src ? <img src={src} alt="" /> : <Icon name="image" size={22} />}
      <span className="pf-cat-photo-edit"><Icon name={busy ? "refresh" : "upload"} size={16} />{busy ? t.uploading : label}</span>
    </span>
  );
}

function PickButton({ src, label }: { src: string | null; label: string }) {
  const { pending } = useFormStatus();
  return <Tile src={src} label={label} busy={pending} />;
}

/** Click the tile, pick a photo, and it uploads straight away. */
export function CategoryPhoto({ name, coverUrl, source, upload, remove }: {
  name: string;
  coverUrl: string | null;
  source: "uploaded" | "product" | "none";
  upload: (fd: FormData) => void;
  remove: (fd: FormData) => void;
}) {
  const form = useRef<HTMLFormElement>(null);
  const input = useRef<HTMLInputElement>(null);
  const [error, setError] = useState<string | null>(null);
  const t = useDict().categories;

  return (
    <div className="pf-cat-photo-wrap">
      <form ref={form} action={upload}>
        <button type="button" className="pf-cat-photo-btn" onClick={() => input.current?.click()} aria-label={t.changeFor(name)}>
          <PickButton src={coverUrl} label={coverUrl ? t.change : t.addPhoto} />
        </button>
        <input
          ref={input} type="file" name="image" accept="image/jpeg,image/png,image/webp" hidden
          onChange={(e) => {
            const f = e.target.files?.[0];
            if (!f) return;
            if (f.size > 5 * 1024 * 1024) { setError(t.over5); e.target.value = ""; return; }
            setError(null);
            form.current?.requestSubmit();
          }}
        />
      </form>
      <span className="pf-cat-photo-src">
        {error ? <span className="pf-error">{error}</span>
          : source === "uploaded" ? (
            <form action={remove}><button type="submit" className="pf-linkbtn">{t.remove}</button></form>
          ) : source === "product" ? t.fromProduct : t.noPhoto}
      </span>
    </div>
  );
}
