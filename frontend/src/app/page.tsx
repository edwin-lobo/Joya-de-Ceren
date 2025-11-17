import Link from 'next/link';

const highlights = [
  'Create dual-role profiles for vendors and customers',
  'Publish curated product listings with image quotas',
  'Collect reviews with verified purchase badges',
];

export default function Home() {
  return (
    <main className="min-h-screen bg-slate-50 px-6 py-12">
      <section className="mx-auto max-w-4xl rounded-2xl border border-slate-200 bg-white p-10 shadow-lg">
        <p className="text-sm uppercase tracking-[0.3em] text-blue-500">Creative Marketplace</p>
        <h1 className="mt-4 text-4xl font-bold leading-tight text-slate-900">
          Build a multi-role storefront in minutes
        </h1>
        <p className="mt-4 text-lg text-slate-600">
          This MVP ships the essential workflows for vendors, customers, and moderators so you can
          validate the experience before expanding.
        </p>
        <div className="mt-8 flex flex-wrap items-center gap-4">
          <Link
            href="/auth/register"
            className="rounded-md bg-blue-600 px-6 py-3 text-sm font-semibold text-white transition hover:bg-blue-700"
          >
            Register as a vendor
          </Link>
          <p className="text-sm text-slate-500">
            Integrate with the backend once the API contract is finalized.
          </p>
        </div>
      </section>

      <section className="mt-12 grid gap-6 md:grid-cols-3">
        {highlights.map((item) => (
          <article
            key={item}
            className="rounded-xl border border-slate-200 bg-white p-6 shadow-sm"
          >
            <p className="text-sm font-semibold text-slate-500">MVP highlight</p>
            <p className="mt-3 text-lg font-medium text-slate-800">{item}</p>
          </article>
        ))}
      </section>
    </main>
  );
}
