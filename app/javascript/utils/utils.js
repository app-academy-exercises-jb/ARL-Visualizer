export async function getData(data={}) {
  const url = location.origin + "/api/v1/command",
    res = await fetch(url, {
      method: 'POST',
      mode: "cors",
      cache: "no-cache",
      headers: { "Content-Type": "application/json" },
      redirect: "manual",
      body: JSON.stringify({command: data})
    });
  return await res.json();
}