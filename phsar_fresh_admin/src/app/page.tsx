import { redirect } from "next/navigation";
import { getAccess } from "@/lib/auth";
import { homeFor } from "@/lib/permissions";

export default async function Home() {
  redirect(homeFor((await getAccess()).permissions));
}
