import type { ComponentProps, ReactNode } from "react";
import { Icon, type IconName } from "./icon";

interface FieldBase { label?: ReactNode; hint?: ReactNode; error?: string; lang?: string; required?: boolean; className?: string }

function Field({ id, label, hint, error, lang, required, className, children }: FieldBase & { id: string; children: ReactNode }) {
  return (
    <div className={["pf-field", className].filter(Boolean).join(" ")}>
      {label && (
        <label className="pf-label" htmlFor={id}>
          {label}
          {required && <span className="pf-req" aria-hidden>*</span>}
          {lang && <span className="pf-lang">{lang}</span>}
        </label>
      )}
      {children}
      {error ? <span className="pf-error" id={`${id}-msg`}>{error}</span> : hint && <span className="pf-hint" id={`${id}-msg`}>{hint}</span>}
    </div>
  );
}

type InputProps = FieldBase & Omit<ComponentProps<"input">, "prefix" | "className"> & { icon?: IconName; prefix?: ReactNode; suffix?: ReactNode };

export function TextField({ label, hint, error, lang, required, className, icon, prefix, suffix, id, name, ...rest }: InputProps) {
  const fid = id ?? `f-${name}`;
  return (
    <Field id={fid} {...{ label, hint, error, lang, required, className }}>
      <div className={`pf-control${error ? " is-error" : ""}`}>
        {icon && <span className="pf-adorn"><Icon name={icon} size={18} /></span>}
        {prefix && <span className="pf-adorn">{prefix}</span>}
        <input id={fid} name={name} required={required} aria-invalid={error ? true : undefined} aria-describedby={error || hint ? `${fid}-msg` : undefined} {...rest} />
        {suffix && <span className="pf-adorn pf-adorn-end">{suffix}</span>}
      </div>
    </Field>
  );
}

export function TextArea({ label, hint, error, lang, required, className, id, name, ...rest }: FieldBase & Omit<ComponentProps<"textarea">, "className">) {
  const fid = id ?? `f-${name}`;
  return (
    <Field id={fid} {...{ label, hint, error, lang, required, className }}>
      <div className={`pf-control is-multi${error ? " is-error" : ""}`}>
        <textarea id={fid} name={name} required={required} {...rest} />
      </div>
    </Field>
  );
}

export function Select({ label, hint, error, required, className, id, name, options, placeholder, ...rest }: FieldBase &
  Omit<ComponentProps<"select">, "className"> & { options: { value: string; label: string }[]; placeholder?: string }) {
  const fid = id ?? `f-${name}`;
  return (
    <Field id={fid} {...{ label, hint, error, required, className }}>
      <div className={`pf-control${error ? " is-error" : ""}`}>
        <select id={fid} name={name} required={required} {...rest}>
          {placeholder !== undefined && <option value="">{placeholder}</option>}
          {options.map((o) => <option key={o.value} value={o.value}>{o.label}</option>)}
        </select>
        <span className="pf-select-chev"><Icon name="chevron-down" size={16} /></span>
      </div>
    </Field>
  );
}

/** English left, Khmer right — for every customer-facing name and description. */
export function BilingualField({ label, required, multiline, nameEn, nameKm, defaultEn, defaultKm, errorEn, errorKm, hint, placeholderEn, placeholderKm, labelEn = "English", labelKm = "Khmer" }: {
  label: string; labelEn?: string; labelKm?: string; required?: boolean; multiline?: boolean; nameEn: string; nameKm: string;
  defaultEn?: string | null; defaultKm?: string | null; errorEn?: string; errorKm?: string; hint?: string;
  placeholderEn?: string; placeholderKm?: string;
}) {
  const C = multiline ? TextArea : TextField;
  return (
    <div className="pf-field">
      <span className="pf-label">{label}{required && <span className="pf-req" aria-hidden>*</span>}</span>
      <div className="pf-bilingual">
        <C label={labelEn} lang="EN" name={nameEn} required={required} defaultValue={defaultEn ?? ""} error={errorEn} placeholder={placeholderEn} />
        <C label={labelKm} lang="ខ្មែរ" className="pf-km" name={nameKm} defaultValue={defaultKm ?? ""} error={errorKm} placeholder={placeholderKm} />
      </div>
      {hint && <span className="pf-hint">{hint}</span>}
    </div>
  );
}

export function Switch({ name, label, defaultChecked }: { name: string; label: ReactNode; defaultChecked?: boolean }) {
  return (
    <label className="pf-switch">
      <input type="checkbox" role="switch" name={name} defaultChecked={defaultChecked} />
      <span className="pf-switch-track" />
      {label}
    </label>
  );
}

export function Checkbox({ name, label, defaultChecked }: { name: string; label: ReactNode; defaultChecked?: boolean }) {
  return (
    <label className="pf-check">
      <input type="checkbox" name={name} defaultChecked={defaultChecked} />
      {label}
    </label>
  );
}
