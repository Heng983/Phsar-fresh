/** Short code staff and customers read out: PF-1A2B3C. */
export const orderCode = (id: string) => `PF-${id.slice(0, 6).toUpperCase()}`;
