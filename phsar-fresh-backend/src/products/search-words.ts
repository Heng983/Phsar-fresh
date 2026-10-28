// keeps a long query from turning into a huge SQL filter
const MAX_WORDS = 8;

/**
 * Splits a search query into lowercase words, e.g.
 * "Kampot, black pepper!" -> ["kampot", "black", "pepper"].
 * Only splits on spaces and ASCII punctuation so Khmer text stays intact.
 */
export function toSearchWords(query: string): string[] {
  const words = query
    .toLowerCase()
    .split(/[\s.,;:!?'"()[\]{}\/\\|+*&-]+/)
    .filter(Boolean);

  return [...new Set(words)].slice(0, MAX_WORDS);
}
