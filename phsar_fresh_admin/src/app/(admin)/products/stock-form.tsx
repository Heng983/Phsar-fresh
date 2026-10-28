"use client";

import { useActionState } from "react";
import { SubmitButton } from "@/components/client";
import { TextField } from "@/components/fields";
import { Icon } from "@/components/icon";
import { useDict } from "@/i18n/client";
import { updateStock, type StockFormState } from "./actions";

export function StockForm({ id, stock, unit }: { id: string; stock: number; unit: string }) {
  const [state, action] = useActionState<StockFormState, FormData>(updateStock.bind(null, id), {});
  const t = useDict().productForm;
  return (
    <form action={action} className="pf-form-grid">
      {state.error && <div className="pf-alert pf-alert-danger" role="alert"><Icon name="alert" size={18} /><div className="pf-alert-title">{state.error}</div></div>}
      {state.saved && <div className="pf-alert pf-alert-success" role="status"><Icon name="check" size={18} /><div className="pf-alert-title">{t.stockUpdated}</div></div>}
      <TextField label={t.inStock} name="stock" type="number" min={0} step={1} required defaultValue={state.stock ?? String(stock)} suffix={unit} hint={t.stockHint} />
      <SubmitButton icon="check">{t.updateStock}</SubmitButton>
    </form>
  );
}
