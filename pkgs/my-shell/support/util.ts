import { exec, readFile, writeFile } from "astal";

export const format = (bytes: number): string => {
  if (!Number.isFinite(bytes) || bytes < 0)
    throw new Error("Invalid byte value");
  if (bytes === 0) return "0 B";
  const sizes = ["B", "KB", "MB", "GB", "TB", "PB"];
  const i = Math.max(
    0,
    Math.min(sizes.length - 1, Math.floor(Math.log(bytes) / Math.log(1024)))
  );
  const value = bytes / Math.pow(1024, i);
  return `${parseFloat(value.toFixed(2))} ${sizes[i]}`;
};

export function readJSONFile(filePath: string): any {
  if (readFile(filePath) == "") return {};
  try {
    const data = readFile(filePath);
    return data.trim() ? JSON.parse(data) : {};
  } catch (e) {
    console.log(e);
    return {};
  }
}

export function writeJSONFile(filePath: string, data: any) {
  if (readFile(filePath) == "")
    exec(`mkdir -p ${filePath.split("/").slice(0, -1).join("/")}`);
  try {
    writeFile(filePath, JSON.stringify(data, null, 4));
  } catch (e) {
    console.log(e);
  }
}
