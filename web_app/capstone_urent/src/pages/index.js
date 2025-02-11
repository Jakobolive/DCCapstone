import { useEffect, useState } from "react";

export default function Home() {
  const [name, setName] = useState("Sample")

  useEffect(() => {
    console.log("hello")
  }, []);

  return (
    <h1>URent is a dating site like application, but instead of two people searching for a relationship,
      URent has either a Tenant looking for a listing, or a landlord looking for a possible Tenant.
      Sign up and choose if you a tenant, or landlord, give your preferences, and start searching.
    </h1>
  );
}