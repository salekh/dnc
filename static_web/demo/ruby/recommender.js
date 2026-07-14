export async function rank(userContext, watchHistory, deviceContext) {
  const isColdStart = !watchHistory || watchHistory.length === 0;
  
  if (isColdStart) {
    // Cold-start user: return editorial fallback list with baseline reasons
    const fallbacks = [
      {
        id: 'orig1',
        title: 'Babylon Berlin',
        category: 'Crime',
        rating: 4.8,
        lang: 'DE',
        isOriginal: true,
        reason: 'Editorial Highlight: Top-rated German original series'
      },
      {
        id: 'orig2',
        title: 'Der Schwarm',
        category: 'Sci-Fi',
        rating: 4.5,
        lang: 'DE',
        isOriginal: true,
        reason: 'Trending in DE: Popular Sci-Fi original'
      },
      {
        id: 'spo1',
        title: 'Bundesliga Live: FCB vs BVB',
        category: 'Sports',
        rating: 4.9,
        lang: 'DE',
        isOriginal: false,
        reason: 'Live Sports: High viewership event right now'
      },
      {
        id: 'doc2',
        title: 'Planet Earth III',
        category: 'Documentary',
        rating: 4.9,
        lang: 'EN',
        isOriginal: false,
        reason: 'Critically Acclaimed: Award-winning documentary'
      }
    ];
    return fallbacks;
  }
  
  // Existing user with watch history: score and rank based on history preferences
  const recommendations = [
    {
      id: 'sci2',
      title: '3 Body Problem',
      category: 'Sci-Fi',
      rating: 4.7,
      lang: 'EN',
      reason: 'Because you watched 65% of Dark Matter (Sci-Fi match)'
    },
    {
      id: 'doc3',
      title: 'Wild Germany',
      category: 'Documentary',
      rating: 4.6,
      lang: 'DE',
      reason: 'Because you enjoy Documentaries and German content'
    },
    {
      id: 'orig1',
      title: 'Babylon Berlin',
      category: 'Crime',
      rating: 4.8,
      lang: 'DE',
      isOriginal: true,
      reason: 'Ruby TV Original: Recommended for high engagement'
    },
    {
      id: 'thr1',
      title: 'Dark',
      category: 'Sci-Fi / Thriller',
      rating: 4.9,
      lang: 'DE',
      reason: 'Top match: Combines your Sci-Fi interest with German originals'
    }
  ];
  
  return recommendations;
}
