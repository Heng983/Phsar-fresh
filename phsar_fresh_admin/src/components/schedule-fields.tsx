"use client";

import { useState } from "react";
import { TextField } from "./fields";
import { useDict } from "@/i18n/client";

/**
 * Starts / Ends (datetime-local, Phnom Penh time) with a "No end date" switch.
 * While the switch is on, Ends is disabled, so the form sends no end date and
 * the server stores null — the item runs until it is turned off.
 */
export function ScheduleFields({ startsAt, endsAt }: { startsAt: string; endsAt: string }) {
  const t = useDict().promotions;
  const [noEnd, setNoEnd] = useState(!endsAt);
  const [end, setEnd] = useState(endsAt);
  return (
    <>
      <div className="pf-two">
        <TextField label={t.starts} name="startsAt" type="datetime-local" defaultValue={startsAt} hint={t.startsHint} />
        <TextField
          label={t.ends}
          name="endsAt"
          type="datetime-local"
          value={noEnd ? "" : end}
          onChange={(e) => setEnd(e.target.value)}
          disabled={noEnd}
          required={!noEnd}
          hint={noEnd ? t.neverExpires : undefined}
        />
      </div>
      <label className="pf-switch">
        <input type="checkbox" role="switch" checked={noEnd} onChange={(e) => setNoEnd(e.target.checked)} data-testid="no-end-date" />
        <span className="pf-switch-track" /> {t.noEndSwitch}
      </label>
    </>
  );
}
