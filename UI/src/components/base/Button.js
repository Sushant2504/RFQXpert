import { cn } from "@/lib/utils";
import { Icon } from "@iconify/react";
import { useRef } from "react";
import { useRouter } from "next/navigation";

export function Button({
  href,
  icon,
  leading,
  label,
  size = "base",
  color = "dark",
  variant = "solid",
  block = false,
  onClick,
  className,
  openFile = false, // Enable file picker
}) {
  const inputRef = useRef(null);
  const router = useRouter();

  const handleClick = (e) => {
    if (openFile) {
      e.preventDefault();
      inputRef.current?.click();
    } else if (onClick) {
      onClick(e);
    }
  };

  const handleFileChange = (e) => {
    const files = e.target.files;
    if (files && files.length > 0) {
      const file = files[0];
      if (file.type === "application/pdf") {
        router.push("/upload");
      } else {
        alert("Only PDF files are allowed.");
      }
    }
  };

  const iconClass = cn(
    { "size-5": size === "base" },
    { "size-4": size === "small" },
    { "group-hover:translate-x-1 duration-100 ease-in-out": variant === "link" }
  );

  const Tag = href && !openFile ? "a" : "button";

  return (
    <>
      <Tag
        href={href}
        onClick={handleClick}
        className={cn(
          "group inline-flex gap-2 items-center rounded-full leading-none duration-200 ease-in-out",
          {
            "text-sm px-6 py-4": size === "base",
            "text-sm px-4 py-2": size === "small",
          },
          {
            "bg-primary-500 text-primary-50 hover:bg-primary-600":
              color === "primary" && variant === "solid",
            "text-primary-500 bg-transparent px-0 py-1":
              color === "primary" && variant === "link",

            "bg-base-800 text-base-50 hover:bg-base-950 dark:invert":
              color === "dark",
            "bg-base-200 text-base-600 hover:bg-white dark:invert":
              color === "light",
            "bg-white text-base-600 hover:bg-base-200": color === "white",
            "bg-transparent text-base-600 ": color === "transparent",
          },
          { "hover:scale-95": variant !== "link" },
          { "w-full justify-center": block },
          className
        )}
      >
        {leading && icon && <Icon icon={icon} className={iconClass} />}
        {label}
        {!leading && icon && <Icon icon={icon} className={iconClass} />}
      </Tag>

      {openFile && (
        <input
          type="file"
          ref={inputRef}
          style={{ display: "none" }}
          onChange={handleFileChange}
          accept="application/pdf" // ✅ Only allow PDF
          multiple={false} // ✅ Only one file
        />
      )}
    </>
  );
}
