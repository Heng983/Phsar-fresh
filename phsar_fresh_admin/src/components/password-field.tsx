"use client";

import { useState, type ComponentProps } from "react";
import { TextField } from "./fields";
import { Icon } from "./icon";
import { useDict } from "@/i18n/client";

/** A password input with a show / hide eye button. */
export function PasswordField(props: Omit<ComponentProps<typeof TextField>, "type" | "suffix">) {
  const [shown, setShown] = useState(false);
  const t = useDict().common;
  return (
    <TextField
      {...props}
      type={shown ? "text" : "password"}
      suffix={
        <button
          type="button"
          className="pf-reveal"
          onClick={() => setShown((v) => !v)}
          aria-label={shown ? t.hidePassword : t.showPassword}
          aria-pressed={shown}
          title={shown ? t.hidePassword : t.showPassword}
        >
          <Icon name={shown ? "eyeOff" : "eye"} size={18} />
        </button>
      }
    />
  );
}
