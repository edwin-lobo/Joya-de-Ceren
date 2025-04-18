import Image from "next/image"; // Standard Image component (may need config or switch to <img>)

export default function Home() {
  // Placeholder data - Fetch from your API later
  const products = [
    { id: 1, name: "Amazing Artwork Print", price: "$49.99", imageUrl: "/placeholder-image.jpg" },
    { id: 2, name: "Handcrafted Mug", price: "$24.99", imageUrl: "/placeholder-image.jpg" },
  ];

  return (
    <main className="flex min-h-screen flex-col items-center justify-between p-24">
      <h1 className="text-4xl font-bold mb-8">Creative Marketplace</h1>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {products.map((product) => (
          <div key={product.id} className="border rounded-lg p-4 shadow-lg">
            {/* Using standard img tag due to unoptimized: true in next.config */}
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
                src={product.imageUrl} // Ensure you have a placeholder in public/
                alt={product.name}
                className="w-full h-48 object-cover mb-4 rounded"
                width={300} // Provide width/height for layout stability
                height={192}
             />
            {/* Or configure a custom loader for Next Image if preferred */}
            {/* <Image src={product.imageUrl} alt={product.name} width={300} height={200} className="w-full h-48 object-cover mb-4 rounded" /> */}
            <h2 className="text-xl font-semibold">{product.name}</h2>
            <p className="text-lg text-gray-700">{product.price}</p>
            <button className="mt-4 bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
              View Details
            </button>
          </div>
        ))}
      </div>
    </main>
  );
}

// Add placeholder styles to frontend/src/app/globals.css if needed, especially if not using Tailwind
